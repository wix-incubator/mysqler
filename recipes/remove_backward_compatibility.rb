Chef::Log.debug("Starting run of remove_backward_compatibility") 
if node['mysqler'][:remove_backward_compatibility] == false
   Chef::Log.debug("Stop remove_backward_compatibility because node['mysqler'][:remove_backward_compatibility] is #{node['mysqler'][:remove_backward_compatibility]}")
   return
end
if node['mysqler'][:handle_backward_compatibility] == true
  Chef::Log.debug("node['mysqler'][:remove_backward_compatibility] is #{node['mysqler'][:remove_backward_compatibility]}")
  return
end

directory node['mysqler'][:backward_compatibility][:basedir] do
  action :delete
  recursive true
end

