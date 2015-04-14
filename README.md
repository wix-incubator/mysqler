#A cookbook to install MySQL server and configure instances as needed.

## Description


The cookbook allows you to install mysql server, configure several instances on the same machine based on parameters that should be configured for each server.

## Supported Platforms
Debian


### Chef
Production tested on chef 11.16.4 version.

## Recipes

* `mysqler::default` 	- The default recipe. Performes all basic installation and configuration of mysql server 
* `mysqler::configure_server` - Configures Mysql instance 
* `mysqler::add_repository` - Adds mysql repository 
* `mysqler::build_replica_member` - Creates replication member based on the configuration
* `mysqler::install_mysql_gem` - Installs mysql gem for chef to allow connection and query on remote DB
* `mysqler::install_server` - Installs mysql-server from the repository
* `mysqler::manage_users` - manages system users for mysql 
* `mysqler::poke` - poke the servers to create data for replication. Uses test database and poke table.

#####Additional helper recipes
* `mysqler::handle_backward_compatibility` - add backward compatibility to previously installed version of mysql - linking binaries to their previous location
* `mysqler::remove_backward_compatibility` - remove previously setup backward compatibility

## Important
We **DO** overwrite several attributes of percona cookbook

 `default["percona"]["skip_passwords"] = true`
 
 `default["percona"]["apt_keyserver"] = "keyserver.ubuntu.com"`
 
 `default["percona"]["backup"]["configure"] = false`

## Usage

###Basic

Create a role for each of your mysql database schemas as following:

```
name "mysql_my_app"
description "mysql for my_app"
run_list('recipe[mysqler]')
default_attributes({
  	'mysqler' => {
   		'app_name' => 'my_app',
    	'innodb_buffer_pool_size' => '4G' ,
    		.
    		.
    		.
    		.
    	'mysql_rebuild' => {
      		'xtra_bkp_src' => {
        		'dc_name1' => 'hostname',
        		'dc_name2' => {'host' => 'hostname2', 'master' => 1}
      		},
      		'dump_rebuild_src' => {
        		'dc_name1' => 'hostname'

        	}
    	}
  	}
})
```

###Multi-Instance
Create the following roles:

* `mysql_parent` for the physical server
* `mysql_[appname]` for each instance

For the physical server - perform the mysql server installation and create fake chef nodes as needed. You can use our cookbook fake-chef-client for that purpose.

```
name "mysql_parent"
description "mysql parent server"
run_list('recipe[mysqler::install_server]', recipe[fake-chef-client])
default_attributes({
})
```
Create a role for each of your mysql database schemas as following:

```
name "mysql_my_app"
description "mysql parent server"
run_list('recipe[mysqler::configure_server]')
default_attributes({
  	'mysqler' => {
    	'app_name' => 'my_app',
    	'innodb_buffer_pool_size' => '4G' ,
    		.
    		.
    		.
    		.
    	'mysql_rebuild' => {
      		'xtra_bkp_src' => {
        		'dc_name1' => 'hostname',
        		'dc_name2' => {'host' => 'hostname2', 'master' => 1}
      		},
      		'dump_rebuild_src' => {
        		'dc_name1' => 'hostname'

        	}
    	}
  	}
})
```

## Databags

Databag examples can be found in `databag_examples` folder

## Acknowledgements

This cookbook was forked from percona cookbook several years ago, and was changed since.

## Supplementary Cookbook
`fake-chef-client` - <A>https://github.com/wix/fake-chef-client</a>

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
 Authors: Wix.com

 License: Apache 2.0
