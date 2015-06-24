return unless node['mysqler']["poke_needed"]
passwords = Chef::EncryptedDataBagItem.load(node['mysqler']['passwords']['databag'], node['mysqler']['passwords']['item'])

template node['mysqler']["poke_file"] do
  source "poke.sql.erb"
  cookbook node['mysqler']["templates_cookbook"]
  owner "root"
  group "root"
  mode "0600"
  only_if {node['mysqler']["poke_needed"]}
end

execute "poke mysql slaves" do
  command "mysql --defaults-file=#{node['mysqler']["defaults-file"]} -p#{passwords['users'][node['mysqler']["master_user"]]['password']} < #{node['mysqler']["poke_file"]}"
  if Gem::Version.new(Chef::VERSION) < Gem::Version.new(node['mysqler']["replace_exec_provider_before_version"])
    Chef::Log.debug("Replacing Execute provider to hide details")
    provider Chef::Provider::MyExecute 
  end
  sensitive true
  only_if {node['mysqler']["poke_needed"]}
end

cron "#{node["mysqler"]["service_name"]} poke" do
  minute node['mysqler'][:poke][:cron_minute]
  hour node['mysqler'][:poke][:cron_hour]
  command "/usr/bin/mysql --defaults-file=#{node['mysqler']['defaults-file']} -u#{node['mysqler'][:poke][:poke_user]} -p#{passwords['users'][node['mysqler'][:poke][:poke_user]]['password']} #{node['mysqler'][:poke][:poke_db]}  -e\"replace into #{node['mysqler'][:poke][:poke_table]} values ('#{node[:fqdn]}',now());\" >/dev/null 2>&1"
  only_if {node['mysqler']["poke_needed"] && node['mysqler'][:poke][:add_to_cron]}
end
