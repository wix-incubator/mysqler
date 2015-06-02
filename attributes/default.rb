#
# Cookbook Name:: mysqler
# Attributes:: mysqler
#
# origin - at percona cookbook percona- default
#

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default['mysqler']['basedir']                         = "/usr"

default['mysqler']['passwords']['databag']            = "passwords"
default['mysqler']['passwords']['item']               = "mysql"

default['mysqler']['templates_cookbook']              = "mysqler"
default['mysqler']['salt']                            = "some salt for automatic password creation"

default['mysqler']['app_name']                        = nil
default['mysqler']['force_appname']                   = false #use this to disallow configuration of mysql instance without appname

default['mysqler']['users_databag_name']                   = 'users'
default['mysqler']['users_databag_item']              = node['mysqler']['app_name']

default['mysqler']['auto_restart']                    = false #don't change to true in production
default['mysqler']['master_user']                     = 'root'
default['mysqler']['master_user_privileges']          = 'ALL PRIVILEGES'
#update this attribute to hold your real networks to be used as default for grants
default['mysqler']['networks']                        =  ['127.0.0.1', 'localhost']
default['mysqler']['master_user_networks']            =  ['127.0.0.1', 'localhost']




default['mysqler']['poke_needed']                     = true
default['mysqler']['fix_directory_permissions']       = true #this is usefull when need to upadte existing directory permissions
default['mysqler']['hostname']                        = node['fqdn']
default['mysqler']['create_initscript']               = true
default['mysqler'][:memory_factor]                    = 0.7

if !node['mysqler']['app_name'].to_s.empty?
  default['mysqler']['service_name']                  = "mysql_#{node['mysqler']['app_name']}"
  default['mysqler']['socket']                        = "/var/run/mysqld/mysqld_#{node['mysqler']['app_name']}.sock"
  default['mysqler']['defaults-file-dir']             = "/etc/mysql"
  default['mysqler']['defaults-file-name']            = "my_#{node['mysqler']['app_name']}.cnf"
  default['mysqler']['pidfile']                       = "/var/run/mysqld/mysqld_#{node['mysqler']['app_name']}.pid"
  default['mysqler']['homedir']                       = "/var/lib/mysql/#{node['mysqler']['app_name']}/"
  default['mysqler']['includedir']                    = "#{node['mysqler']['defaults-file-dir']}/#{node['mysqler']['app_name']}_conf.d/"
  
else
  default['mysqler']['service_name']                  = "mysql"
  default['mysqler']['socket']                        = "/var/run/mysqld/mysqld.sock"
  default['mysqler']['defaults-file-dir']             = "/etc/mysql"
  default['mysqler']['defaults-file-name']            = "my.cnf"
  default['mysqler']['homedir']                       = "/var/lib/mysql"
  default['mysqler']['includedir']                    = "#{node['mysqler']['defaults-file-dir']}/conf.d/"
  default['mysqler']['pidfile']                       = "/var/run/mysqld/mysqld.pid"
end

default['mysqler']['initscript']                    = "/etc/init.d/#{node['mysqler']['service_name']}"
default['mysqler']['all_grants_file']                 = "#{node['mysqler']['includedir']}/grants.sql"
default['mysqler']['poke_file']                       = "#{node['mysqler']['includedir']}/poke.sql"
default['mysqler']['dpkg_cnf']                        = "/etc/dpkg/dpkg.cfg.d/mysql"
default['mysqler']['dpkg_template']                   = "dpkg.erb"

default['mysqler']['initscript_template']             = "mysql.server.erb"
default['mysqler']['defaults_file_template']          = "my.cnf.erb"
default['mysqler']['check_available_memory'] = true

#to never replace provider configure very high version like '1000'
default['mysqler']['replace_exec_provider_before_version'] = "12"


# Start mysql server on boot
default['mysqler']['enable']                          = true

# Basic Settings
default['mysqler']['default_storage_engine']          = "InnoDB"
default['mysqler']['defaults-file']                   = "#{node['mysqler']['defaults-file-dir']}/#{node['mysqler']['defaults-file-name']}"
default['mysqler']['role']                            = "standalone"
default['mysqler'][:manage_users]                     = false
default['mysqler'][:username]                         = "mysql"
default['mysqler'][:usergroup]                        = "mysql"
default['mysqler']['datadir']                         = "#{node['mysqler']['homedir']}/data"
default['mysqler']['tmpdir']                          = "#{node['mysqler']['homedir']}/tmp"
default['mysqler']['logdir']                          = "#{node['mysqler']['homedir']}/log"
default['mysqler']['journaldir']                      = "#{node['mysqler']['homedir']}/journal"
default['mysqler']['binarydir']                       = "#{node['mysqler']['homedir']}/binary"
default['mysqler']['relaydir']                        = "#{node['mysqler']['homedir']}/relay"
default['mysqler']['nice']                            = 0
default['mysqler']['open_files_limit']                = 16384
default['mysqler']['port']                            = 3306
default['mysqler']['bind_address']                    = node['fqdn'].to_ip || "127.0.0.1"


# Logging and Replication

default['mysqler']['server_id']                       = ip_to_server_id(node['fqdn'].to_ip) 
default['mysqler']['log_error']                       = "#{node['mysqler']['logdir']}/#{node['mysqler']['hostname']}.err"
default['mysqler']['general_log']                     = 0
default['mysqler']['general_log_file']                = "#{node['mysqler']['logdir']}/#{node['mysqler']['hostname']}-general.log"
default['mysqler']['sync_binlog']                     = 1
default['mysqler']['slow_query_log']                  = 1
default['mysqler']['slow_query_log_file']             = "#{node['mysqler']['logdir']}/#{node['mysqler']['hostname']}-slow.log"
default['mysqler']['expire_logs_days']                = 10 
default['mysqler']['max_binlog_size']                 = "1G"
default['mysqler']['log_bin']                         = "#{node['mysqler']['binarydir']}/mysql-bin" 
default['mysqler']['log_bin_index']                   = "#{node['mysqler']['binarydir']}/mysql-bin.index" 
default['mysqler']['relay_log']                       = "#{node['mysqler']['relaydir']}/relay-bin"
default['mysqler']['relay_log_index']                 = "#{node['mysqler']['relaydir']}/relay-bin.index"
default['mysqler']['relay_log_info_file']             = "#{node['mysqler']['relaydir']}/relay-log.info"
default['mysqler']['log_slave_updates']               = false
default['mysqler']['binlog_format']            	      = "MIXED"
default['mysqler']['replication_params']['slave_compressed_protocol'] = 1
default['mysqler']['replication_params']['slave-skip-errors'] = nil
default['mysqler']['replication_params']['replicate-wild-do-table'] = []
default['mysqler']['replication_params']['replicate-ignore-table'] = []
default['mysqler']['replication_params']['replicate-rewrite-db'] = []
default['mysqler']['replication_params']['read_only'] = false
default['mysqler']['replication_params']['binlog_do_db'] = []



## Client ##
default['mysqler']['client']['prompt']                = '\u@\h('+(node['mysqler']['hostname'][/(^.*)\..*\..*/,1] || node['fqdn'] rescue 'localhost')+'):[\d]>\_' 
default['mysqler']['client']['no_auto_rehash']        = false

