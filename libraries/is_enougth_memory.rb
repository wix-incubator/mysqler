def size_to_s(int_size = 0)
  int_size = int_size.to_i
  {
      'B' => 1024,
      'K' => 1024 * 1024,
      'M' => 1024 * 1024 * 1024,
      'G' => 1024 * 1024 * 1024 * 1024
  }.each_pair { |e, s| return "#{(int_size / (s / 1024))}#{e}" if int_size < s}  
end

def from_size_to_i(string_size)
  sizes = { 
    'K' => '*1024', 
    'M' => '*1024*1024', 
    'G' => '*1024*1024*1024' 
  }
  string_size = string_size.strip rescue '0'
  size = eval((string_size.split('').map { | c | c= sizes[c] || c }).join())
  size.to_i
end

def is_enough_memory req_memory
  #first of all verify that this server has currently enough RAM for that service
  Chef::Log.debug( "Memory for mysql check. Start req_memory=#{req_memory}, node['mysqler'][\"defaults-file\"] = #{node['mysqler']["defaults-file"]} " ) 
  curr_free_memory = `free | head -3 | tail -1| sed -e 's/-\\/+ buffers\\/cache:[ ]*[0-9]*[ ]*\\([0-9]*\\)/\\1/'`.to_i*1024

  requested_memory = from_size_to_i(req_memory)

  #verify that all mysql buffer pools will not take more than 80% of the RAM
  total_memory=`free | head -2 | tail -1| sed -e 's/Mem: *\\([0-9]*\\).*/\\1/'`.to_i*1024
  max_for_innodb_buffers=(total_memory*node['mysqler'][:memory_factor]).to_i


  #current memory should be tested for new files or memory change only
  Chef::Log.debug("Memory for mysql check . requested_memory = #{size_to_s(requested_memory)} , curr_free_memory = #{size_to_s(curr_free_memory)} ")
  if File.file?(node['mysqler']["defaults-file"]) 
    #if changing config of the memory for application:
    old_memory = from_size_to_i(`grep 'innodb_buffer_pool_size' #{node['mysqler']["defaults-file"]} | cut -d "=" -f 2 ` )
    if requested_memory == old_memory
      Chef::Log.debug( "Memory for mysql instance will not change. Skipping the check") 
      return true
    end
    
    Chef::Log.debug( "Memory for mysql instance will change from #{size_to_s(old_memory)} to #{size_to_s(req_memory)}") 
    curr_free_memory += old_memory
  end
  
  Chef::Log.debug( "Memory for mysql is minimum from #{size_to_s(curr_free_memory)} and #{size_to_s(max_for_innodb_buffers)}")
  curr_free_memory = [curr_free_memory, max_for_innodb_buffers].min


  #no config file exists or memory allocation being changed.
  if  (curr_free_memory < requested_memory )
    Chef::Log.debug( "Not enough memory for mysql instance. Current free memory #{size_to_s(curr_free_memory)} and needed #{(requested_memory )}")
    return false
  else
    Chef::Log.debug("Enougth memory for mysql instance. Current free memory #{size_to_s(curr_free_memory)} and need #{size_to_s(requested_memory)}")
  end

  

  #check currently configured buffers
  currently_used_for_buffers = from_size_to_i(`grep -HR 'innodb_buffer_pool_size' #{node['mysqler']["defaults-file-dir"]}* | grep -v #{node['mysqler']["defaults-file"]} | sed -e 's/.*=[ ]//' | sed -e :a -e 'N;s/\\n/+/;ta'`)

  if  (currently_used_for_buffers + requested_memory) > max_for_innodb_buffers 
    Chef::Log.debug( "Not enough memory for mysql instance. Currently used for buffers #{size_to_s(currently_used_for_buffers)}. "+ \
    "New val #{size_to_s(currently_used_for_buffers + requested_memory)}") 
    return false
  else
    Chef::Log.debug("Enougth memory for mysql instance. Current buffers #{size_to_s(currently_used_for_buffers)} . New val #{size_to_s(currently_used_for_buffers + requested_memory)}")
  end

  return true
end
