def get_rebuild_src rebuild_src, type
  require 'mysql2'
  if !rebuild_src
    Chef::Log.debug("#{type} is nil")
    return nil,nil,nil
  end
  if rebuild_src.class == String
    Chef::Log.debug("#{type} is string #{rebuild_src}" )
    #dump from slave. return this host
    return rebuild_src, nil, 0 
  end

  if rebuild_src.has_key?("host")
    Chef::Log.debug("#{type} is hash may be master configured #{rebuild_src["host"]}, port = #{ rebuild_src['port']}, master=#{rebuild_src["master"]}" )
    return rebuild_src["host"], rebuild_src['port'], rebuild_src["master"]

  end

  #handle per location config
  server_group_identifier = node['mysqler']["mysql_rebuild"]["server_group_identifier"]
  Chef::Log.debug("Handle per server_group_identifier src for #{server_group_identifier} " )
  if rebuild_src.has_key?(server_group_identifier)
    Chef::Log.debug("get #{type} from  #{rebuild_src[server_group_identifier]}")
    #do a recursion to this function for that location
    return get_rebuild_src(rebuild_src[server_group_identifier],type)
  else
    #try to check the default group identifier  
    default_server_group_identifier = node['mysqler']["mysql_rebuild"]["default_server_group_identifier"]

    if default_server_group_identifier && default_server_group_identifier.length>0
      Chef::Log.debug("no #{type} found for server_group_identifier #{server_group_identifier}.")
      if rebuild_src.has_key?(default_server_group_identifier) && default_server_group_identifier!=server_group_identifier
        Chef::Log.debug("Checking default #{default_server_group_identifier}")
        return get_rebuild_src(rebuild_src[default_server_group_identifier],type)
      else
        return nil, nil, nil
      end
    else
      Chef::Log.debug("no default_server_group_identifier set")
    end
  end
  return nil, nil, nil
end
