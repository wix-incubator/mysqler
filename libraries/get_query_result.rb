def get_query_result username, password,  query, host="localhost", port = 3306,  defaults_file = nil
  Chef::Log.debug("Running get_query_result with params: username = #{username} , query = #{query}, host = #{host}, port = #{port}, defaults_file = #{defaults_file}") 
  begin
    if defaults_file
      client = Mysql2::Client.new(:default_file => defaults_file , :username => username, :password => password)
    elsif host
      client = Mysql2::Client.new(:host => host, :port => port , :username => username, :password => password)
    end
  rescue Exception => e
    Chef::Log.info("Can not connect to the server #{host} #{defaults_file}for query #{query}. Error : #{e}")
    raise e
  end
  if client
    results = client.query(query)
    result_arr = []
    results.each do | res |
      Chef::Log.debug("Query result: #{res.inspect}")
      result_arr << res 
    end
    #p result_arr
    result_arr
    #results
  else
    Chef::Log.info("Can not connect to the server #{host} #{defaults_file}for query #{query}")
  end
end  

  
def get_query_result_single_value username, password,  query, column, host="localhost", port=3306, defaults_file = nil

    result = get_query_result username, password,  query, host, port , defaults_file

    return result[0][column] rescue nil 
    
end
