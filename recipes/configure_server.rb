include_recipe 'mysqler::systemd'
app_name = node['mysqler']["app_name"]
service_name = node['mysqler']['service_name']
raise "App_name is not set for mysql server configuration"  if (app_name.nil? && node['mysqler']["force_appname"])
  
mysql_passwd=get_pass(node['mysqler']['master_user'])

if node['mysqler']["check_available_memory"]  
  if not is_enough_memory(node['mysqler']["innodb_buffer_pool_size"])
    raise "Not enough memory for this setup"
  end 
else
  Chef::Log.debug("check_available_memory turned off")
end 

#copy init script
template node['mysqler']["initscript"] do
  source node['mysqler']['initscript_template']
  cookbook node['mysqler']['templates_cookbook']
  mode 0744
  only_if { node['mysqler']["create_initscript"] == true}
end

# setup the main server config file
defaults_file=node['mysqler']["defaults-file"]

template defaults_file do
  source node['mysqler']['defaults_file_template'] 
  cookbook node['mysqler']['templates_cookbook']
  owner "root"
  group "root"
  mode 0744
  if node['mysqler']["auto_restart"]
    notifies :restart, "service[#{service_name}]", :immediately 
  end
end

homedir= (node['mysqler']["homedir"]) 
user    = node['mysqler']["username"] 
group   = node['mysqler'][:usergroup]
# define the service
service service_name do
  supports :restart => true, :status => true
  action node['mysqler']["enable"] ? :enable : :disable
end

# setup the mysql directory
directory homedir do
  owner user
  group group
  recursive true
  action :create
end


%w{datadir tmpdir logdir journaldir binarydir relaydir}.each do |d| 
  directory node['mysqler'][d] do
    owner user
    group group
    recursive true
    action :create
    mode 0750
  end
end

if !node['mysqler']["includedir"].empty?
  directory node['mysqler']["includedir"]
end


#fix the permission on the directory if the group was changed
execute "fixup #{homedir} ownership" do
  command "chown -Rf #{user}:#{group} #{homedir}"
  only_if { node['mysqler']['fix_directory_permissions'] }
  ignore_failure  true
end
execute "fixup #{homedir} permissions" do
  command "chmod -R 750 #{homedir}"
  only_if { node['mysqler']['fix_directory_permissions'] }
  ignore_failure  true
end

################################


# install db to the data directory
execute "setup new mysql" do
  command "mysql_install_db --defaults-file=#{defaults_file} --user=#{user} "
  not_if "test -f #{node['mysqler']['datadir']}/mysql/user.frm"
end

service service_name do
  action :start
end

#create alias if app_name is used
if node['mysqler']["service_name"] != 'mysql'
  magic_shell_alias node['mysqler']["service_name"] do
    command "mysql --defaults-file=#{defaults_file} -p"
  end
end

logrotate_app node['mysqler']["service_name"] do
  cookbook node['mysqler'][:logrotate][:cookbook]
  path node['mysqler'][:logrotate][:path]
  frequency node['mysqler'][:logrotate][:frequency]
  size node['mysqler'][:logrotate][:size]
  maxsize node['mysqler'][:logrotate][:maxsize]
  rotate node['mysqler'][:logrotate][:rotate]
	postrotate node['mysqler'][:logrotate][:postrotate]
	options node['mysqler'][:logrotate][:options]
  sharedscripts node['mysqler'][:logrotate][:sharedscripts]
  create "644 mysql mysql"
  enable node['mysqler'][:logrotate][:enable]
end

cron "#{node['mysqler']["service_name"]} logrotate" do
  minute node['mysqler'][:logrotate][:cron_minute] 
  hour node['mysqler'][:logrotate][:cron_hour]
  command "/usr/sbin/logrotate /etc/logrotate.d/#{node['mysqler']["service_name"]}"
  only_if {node['mysqler'][:logrotate][:add_to_cron]}
end

include_recipe "mysqler::access_grants"
include_recipe "mysqler::build_replica_member"
include_recipe "mysqler::poke"

