# Cookbook Name:: mysqler
# Attributes:: mysql_rebuild
#
default['mysqler']['mysql_rebuild']['preffer_xtrabackup'] = true
default['mysqler']['mysql_rebuild']['create_from_replica'] = false
default['mysqler']['mysql_rebuild']['dumped_user'] = 'root'
#default['mysqler']['mysql_rebuild']['dumped_user_password'] =  get_pass(node['mysqler']['mysql_rebuild']['dumped_user']) 
default['mysqler']['mysql_rebuild']['dump_master'] = false
default['mysqler']['mysql_rebuild']['dump_parameters'] = '-C -q --single-transaction --order-by-primary --set-gtid-purged=OFF --complete-insert -f'
default['mysqler']['mysql_rebuild']['ignore_tables'] = []

default['mysqler']["mysql_rebuild"]['script_dir']          = "/opt/mysqler"

if !node['mysqler']["app_name"].to_s.empty?
  default['mysqler']["mysql_rebuild"]["dump_script_from55"]  ="#{node['mysqler']["mysql_rebuild"]['script_dir']}/#{node['mysqler']['app_name']}_mysqldump_from5.5.sh"
else
  default['mysqler']["mysql_rebuild"]["dump_script_from55"] = "#{node['mysqler']["mysql_rebuild"]['script_dir']}/mysqldump_from5.5.sh"
end  
#below should be set in the role
#this is the server from which the mysqldump should be done


#all below parameters should be set in the role or on the node
#dump_rebuild_src can be one of 3 types.
#1. String - identifying the replica server to dump from
#2. Hash of type :
#   {
#     server_group_identifier1 => "String - identifying the replica server to dump from for server_group_identifier1"
#     server_group_identifier2 => "String - identifying the replica server to dump from for server_group_identifier2"
#   }
#   I use location of the server as server_group_identifier 
#     
default['mysqler']["mysql_rebuild"]["rebuilddir"]  =  "#{node['mysqler']['homedir']}/rebuild"
default['mysqler']["mysql_rebuild"]["server_group_identifier"]  =  node['location']
default['mysqler']["mysql_rebuild"]["default_server_group_identifier"]  =  'local'
default['mysqler']["mysql_rebuild"]["dump_rebuild_src"]  = nil 
default['mysqler']["mysql_rebuild"]["ssh_port"]  = 41278
#default['mysqler']["mysql_rebuild"]["ssh_port"]  = 22
default['mysqler']['mysql_rebuild']['xtra_bkp_src'] = ''
default['mysqler']['mysql_rebuild']['xtra_bkp_from_version'] = '5.6'
default['mysqler']["replication"]["username"]         = 'replica'
#default['mysqler']["replication"]["password"]         = get_pass(node['mysqler']["replication"]["username"])
#default['mysqler']["replication"]["port"]             = 3306
default['mysqler']["replication"]["slave-skip-errors"]= "OFF"
if node['mysqler']['app_name'].to_s.length>0
  default['mysqler']["mysql_rebuild"]['xtra_bkp_script'] = "#{node['mysqler']["mysql_rebuild"]['script_dir']}/#{node['mysqler']['app_name']}_rebuild_by_xtrabackup.sh"
else
  default['mysqler']["mysql_rebuild"]['xtra_bkp_script'] = "#{node['mysqler']["mysql_rebuild"]['script_dir']}/rebuild_by_xtrabackup.sh"
end
default['mysqler']["mysql_rebuild"]['delete_rebuild_files'] = false


default['mysqler']['mysql_rebuild']['schema_changes'] = ''




default['mysqler']["interconnect"]["databag_name"] = "passwords"
default['mysqler']["interconnect"]["databag_item"] = "interconnect"
