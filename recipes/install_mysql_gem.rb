include_recipe "mysqler::add_repository"
package "libmysqlclient-dev" do
  action :nothing
  if node['mysqler'][:packages]['libmysqlclient-dev']['version']
    version node['mysqler'][:packages]['libmysqlclient-dev']['version']
  end
end.run_action(node['mysqler'][:packages]['libmysqlclient-dev'][:action])

chef_gem 'mysql2' do
  action :install
end

begin
  require 'mysql2'
rescue RuntimeError => e
  Chef::Log.debug("require mysql2 failed. need to reinstall mysql2 gem")
  #the following will run 
  #`/opt/chef/embedded/bin/gem pristine mysql2`
  mysqler_chef_gem 'mysql2' do
    action :pristine
  end
  raise "Need to restart chef run as mysql2 gem should be reloaded"
end

