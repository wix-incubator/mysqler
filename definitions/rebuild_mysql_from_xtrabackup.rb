define :rebuild_mysql_from_xtrabackup do
  require 'mysql2'
  mysqler=node['mysqler']
  mysql_rebuild = mysqler['mysql_rebuild']
  rebuild_by_xtrabackup = node['mysqler']["mysql_rebuild"]['xtra_bkp_script']

  dumped_user_password = get_pass(node['mysqler']['mysql_rebuild']['dumped_user'])
  replication_password = get_pass(node['mysqler']["replication"]["username"])

  directory  mysql_rebuild['script_dir']  do
    owner "root"
    group "root"
    mode  "0700"
    recursive true
  end

  dumped_user_password = get_pass(mysql_rebuild['dumped_user'])
  replication_password = get_pass(mysqler["replication"]["username"])
  #check version of src server

  Chef::Log.debug("checking mysql version of #{params[:dump_src]}")
  src_ver = get_query_result_single_value( mysql_rebuild['dumped_user'], dumped_user_password,  "SHOW VARIABLES LIKE 'version'",  'Value', params[:dump_src] , params[:dump_port])

  src_ver=/^[0-9\.]*/.match(src_ver).to_s
  Chef::Log.debug("#{params[:dump_src]} is of version #{src_ver}")
  if Gem::Version.new(src_ver) >= Gem::Version.new(mysql_rebuild['xtra_bkp_from_version'])
    if (params[:rebuild_from_master]==1)
      master_host = params[:dump_src] 
    else
      master_host = get_query_result_single_value( mysql_rebuild['dumped_user'], dumped_user_password,  "SHOW SLAVE STATUS;", 'Master_Host', params[:dump_src] , params[:dump_port])
      Chef::Log.info( "master host is #{master_host}")
    end
    Chef::Log.info("Running xtrabackup restore from #{params[:dump_src]}")
    template  rebuild_by_xtrabackup do
      source "rebuild_by_xtrabackup.erb"
      sensitive true
      cookbook node['mysqler']['templates_cookbook']
      backup false
      variables :host_password => params[:mysql_passwd],
               :dumped_host => params[:dump_src],
               :rebuilding_file => params[:rebuilding_file],
               :ignore_tables => mysql_rebuild[:ignore_tables],
               :rebuild_from_master => params[:rebuild_from_master]||0,
               :staging => mysqler['is_staging'],
               :dumped_user => mysql_rebuild['dumped_user'],
               :dumped_password => dumped_user_password,
               :replica_user => mysqler["replication"]["username"],
               :replica_password => replication_password,
               :app_name  => mysqler['app_name'],
               :master_host  => master_host

      mode 0700
    end

    execute "rebuild-mysql-db" do
      command "#{rebuild_by_xtrabackup} >> #{params[:rebuilding_file]} 2>&1"
      action :run
    end

    #remove the file after executing it
    file rebuild_by_xtrabackup do
      action :delete
      backup false
      only_if { node['mysqler']["mysql_rebuild"]['delete_rebuild_files'] == true }
    end
    
  else
    Chef::Log.info("Can not use xtrabackup, source is of the wrong version")
    Chef::Log.info("Performing dump restore instead")
    rebuild_mysql_from_dump do
      mysql_passwd params[:mysql_passwd]
      dump_src params[:dump_src]
      rebuilding_file params[:rebuilding_file]
    end   
  end
end
