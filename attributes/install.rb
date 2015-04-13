default['mysqler'][:add_mysql_repo]                   = true
default['mysqler'][:mysql_repo_name]                  = 'mysql'
default['mysqler'][:mysql_repo_uri]                   = 'http://repo.mysql.com/apt/debian/'
default['mysqler'][:mysql_repo_key]                   = '8C718D3B5072E1F5'
default['mysqler'][:mysql_repo_keyserver]             = 'keyserver.ubuntu.com'
default['mysqler'][:mysql_repo_components]            = %w[mysql-5.6]
default['mysqler'][:add_mysql_repo_preference]        = true
default['mysqler'][:mysql_repo_glob]                  = '*'
default['mysqler'][:mysql_repo_pin]                   = 'release o=Mysql'
default['mysqler'][:mysql_repo_pin_priority]          = '2000'

default['mysqler'][:mysql_server_package]             = 'mysql-server'
default['mysqler'][:mysql_server_package_version]     = nil # Keep this value nil to get the latest version
default['mysqler'][:mysql_server_package_options]     = '--force-yes -o Dpkg::Options="--no-triggers"'
#specify if to :install or :upgrade the server
default['mysqler'][:mysql_server_package_action]     = :install # :install or :upgrade
default['mysqler'][:mysql_server_remove_default_init_script] = true
default['mysqler'][:remove_postinst_mess]             = false #use with a huge care. this will cause a delete of 
# all of the followin ib_logfile0  ib_logfile1  ibdata1  mysql  performance_schema under /var/lib/mysql
# which were created 


# Use :install, unless you're upgrading mysql on a server
default['mysqler'][:packages]['libmysqlclient-dev'][:action]   = :install

default['mysqler'][:run_additional_recipes]           = %w[percona::toolkit percona::backup]

default['mysqler'][:handle_backward_compatibility]    = false
default['mysqler'][:remove_backward_compatibility]    = false 
default['mysqler'][:backward_compatibility][:basedir] = '/opt/mysql/server-5.6'
default['mysqler'][:backward_compatibility][:new_package] = 'mysql-community-server'

