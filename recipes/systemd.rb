Chef::Log.info ('Checking Systemd')
unless `ls -l /proc/1/exe | grep systemd > /dev/null ; echo $?`.strip.to_s=='0'
  Chef::Log.info('Not a systemd, skipping config')
  return
end
Chef::Log.info ('Starting Systemd configuration')
template "/lib/systemd/system/#{ node['mysqler']['service_name']}.service" do
  cookbook node['mysqler']['templates_cookbook']
  source 'systemd/mysql.service.erb'
  owner "root"
  group "root"
  mode 0644
end
 
template node['mysqler']['mysql-systemd-start'] do
  cookbook node['mysqler']['templates_cookbook']
  source 'systemd/mysql-systemd-start.erb'
  owner "root"
  group "root"
  mode 0755
end
