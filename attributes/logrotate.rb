default['mysqler'][:logrotate][:add_to_cron] = true
default['mysqler'][:logrotate][:cron_hour] = "*"
default['mysqler'][:logrotate][:cron_minute] = 30
default['mysqler'][:logrotate][:enable] = true
default['mysqler'][:logrotate][:path] = ['err','log'].map {|x| node['mysqler']["logdir"]+"/*."+x }
default['mysqler'][:logrotate][:frequency] = 'daily'
default['mysqler'][:logrotate][:size] = '500M'
default['mysqler'][:logrotate][:maxsize] = '500M'
default['mysqler'][:logrotate][:rotate] = 7
default['mysqler'][:logrotate][:cookbook] = 'logrotate'
default['mysqler'][:logrotate][:options] =  ['missingok', 'delaycompress', 'notifempty', 'copytruncate']
default['mysqler'][:logrotate][:postrotate] = "
if test -n \"`ps -ef | grep mysqld | grep '#{node['mysqler']["defaults-file"]}'`\" ; then
/usr/bin/mysqladmin --defaults-file=#{node['mysqler']["defaults-file"]} -u debian-sys-maint flush-logs
fi "

default['mysqler'][:logrotate][:sharedscripts] = true
