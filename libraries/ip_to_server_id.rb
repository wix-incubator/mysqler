def ip_to_server_id(ip)

  Chef::Log.info("the ip is #{ip}")
  ai = ip.split('.')
  
  case ai[0] 
  when "10"
    header = "1"
  when "172"
    header = "2"
  when "192"
    header = "3"
  else
    header = "0"
  end

  header + "%03d" % ai[1] + "%03d" % ai[2] + "%03d" % ai[3]

end
