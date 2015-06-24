include_recipe "mysqler::add_repository"
include_recipe "mysqler::manage_users"
include_recipe 'mysqler::install_mysql_gem'

#adding template to skip the /etc/init.d/mysql file
template node['mysqler']["dpkg_cnf"] do
  action :nothing
  source node['mysqler']["dpkg_template"]
  cookbook node['mysqler']["templates_cookbook"]
  mode 0744
  only_if { node['mysqler']["create_initscript"] }
end.run_action(:create)

execute "clean mysql directory" do
  command "rm -fr /var/lib/mysql/mysql /var/lib/mysql/performance_schema /var/lib/mysql/ibdata1 /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1"
  only_if { node['mysqler'][:remove_postinst_mess] and (node['mysqler']['datadir'] +"/").squeese('/') != '/var/lib/mysql/' }
end

apt_package node['mysqler'][:mysql_server_package] do
  action :nothing
  options node['mysqler'][:mysql_server_package_options]
  version node['mysqler'][:mysql_server_package_version]
  notifies :run, "execute[clean mysql directory]", :immediately
end.run_action(node['mysqler'][:mysql_server_package_action])

include_recipe 'mysqler::handle_backward_compatibility'
  
user = node['mysqler'][:username] 
group = node['mysqler'][:usergroup] 

directory "/var/lib/mysql" do
  owner user
  group group
  mode 0755
  recursive true
end

file '/etc/init.d/mysql' do
  action :delete
  only_if { node['mysqler'][:mysql_server_remove_default_init_script] } 
end

node['mysqler'][:run_additional_recipes].each do |recipe|
  include_recipe recipe
end
