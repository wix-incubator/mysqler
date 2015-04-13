define :rebuild_mysql_from_dump  do
  mysqler=node['mysqler']
  mysql_rebuild = mysqler['mysql_rebuild']
  mysqldump_from55= node['mysqler']["mysql_rebuild"]["dump_script_from55"]
  
  dumped_user_password = get_pass(node['mysqler']['mysql_rebuild']['dumped_user'])
  replication_password = get_pass(node['mysqler']["replication"]["username"])

  directory  mysql_rebuild['script_dir']  do
    owner "root"
    group "root"
    mode  "0700"
    recursive true
  end

  dumped_user_password=get_pass( mysql_rebuild['dumped_user'])
  replication_password=get_pass(mysqler["replication"]["username"])
  #check version of src server
  Chef::Log.debug("checking mysql version of #{params[:dump_src]}")
  src_ver = get_query_result_single_value( mysql_rebuild['dumped_user'], dumped_user_password ,  "SHOW VARIABLES LIKE 'version'",  'Value', params[:dump_src], params[:dump_port])

  src_ver=/^[0-9\.]*/.match(src_ver).to_s
  Chef::Log.debug(" #{params[:dump_src]} is of version #{src_ver}")
  if Gem::Version.new(src_ver) >= Gem::Version.new('5.5')
    template mysqldump_from55 do
      sensitive true
      source "mysqldump_from5.5.erb"
      cookbook node['mysqler']["templates_cookbook"]
      backup false
      variables :host_pass => params[:mysql_passwd],
                :dumped_host => params[:dump_src],
                :dumped_port => params[:dump_port],
                :rebuilding_file => params[:rebuilding_file],
                :ignore_tables => mysql_rebuild[:ignore_tables],
                :rebuild_from_master => params[:rebuild_from_master],
                :staging => mysqler['is_staging'],
                :dumped_user => mysql_rebuild['dumped_user'],
                :dumped_password => dumped_user_password,
                :replica_user => mysqler["replication"]["username"],
                :replica_pass => replication_password
      mode 0700
    end

    execute "rebuild-mysql-db" do
      command mysqldump_from55
      action :run
    end

    #remove the file after executing it
    file mysqldump_from55 do
      action :delete
      backup false
      only_if { node['mysqler']["mysql_rebuild"]['delete_rebuild_files'] == true }
    end
  else #version before 5.5
      Chef::Log.info ("Unsupported rebuild from versions before 5.5")
  end
end

