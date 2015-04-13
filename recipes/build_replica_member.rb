return unless node['mysqler']['mysql_rebuild']['create_from_replica']
include_recipe "mysqler::install_mysql_gem"
mysql_passwd=get_pass(node['mysqler']["master_user"])

app_name=node['mysqler']['app_name']

mysql_rebuild=node['mysqler']['mysql_rebuild'] || {}
ignore_tables=mysql_rebuild['ignore_tables'] || []
rebuilding_file="#{node['mysqler']["homedir"]}/rebuilding"

rebuild_from_replica=mysql_rebuild['create_from_replica'] 


if rebuild_from_replica
  need_to_rebuild =1
  dump_src=mysql_rebuild['dump_rebuild_src']
  dump_user = mysql_rebuild['dumped_user']
  dump_pass = get_pass(dump_user)
  xtrabkp_src = mysql_rebuild['xtra_bkp_src']

  if !xtrabkp_src.empty? && (node['mysqler']['mysql_rebuild']['preffer_xtrabackup'] || dump_src.empty? )
    xtrabkp_src, xtrabkp_port, xtrabkp_rebuild_from_master = get_rebuild_src(mysql_rebuild['xtra_bkp_src'], "xtra_bkp_src")

    if xtrabkp_src
      Chef::Log.debug("final xtrabkp_src is #{xtrabkp_src} port = #{xtrabkp_port} rebuild_from_master= #{xtrabkp_rebuild_from_master}")
      rebuild_mysql_from_xtrabackup  do
        mysql_passwd mysql_passwd
        dump_src xtrabkp_src
        dump_port xtrabkp_port
        rebuilding_file rebuilding_file
        rebuild_from_master xtrabkp_rebuild_from_master
      end
      need_to_rebuild = nil
    else
      Chef::Log.debug("xtrabkp_src was not found")
    end
  end

  if need_to_rebuild && !dump_src.empty? 
    dump_src, dump_port, rebuild_from_master = get_rebuild_src(dump_src, "dump_rebuild_src")

    if dump_src
      Chef::Log.debug("final dump_src is #{dump_src} , port #{dump_port} rebuild_from_master= #{rebuild_from_master}")
      rebuild_mysql_from_dump do
        mysql_passwd mysql_passwd
        dump_src dump_src
        dump_port dump_port
        rebuilding_file rebuilding_file
        rebuild_from_master rebuild_from_master
      end
      need_to_rebuild = nil
    
    end
  end

  if need_to_rebuild
    raise "Does not have xtrabkp_src nor dump_src. need one of those to continue"
  end

else
  log "no need to rebuild"
end

node.set['mysqler']['mysql_rebuild']['create_from_replica']=false
