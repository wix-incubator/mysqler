mysqler=node['mysqler']
mysql_rebuild=node['mysqler']['mysql_rebuild']
mysqldump_from55="#{mysql_rebuild['script_dir']}/#{mysqler['app_name']}_mysqldump_from5.5.sh"

if node['mysqler']["mysql_rebuild"]['delete_rebuild_files']
  file mysqldump_from55 do
    action :delete
    backup false
    only_if { node['mysqler']["mysql_rebuild"]['delete_rebuild_files'] == true }
  end
  
  Chef::Log.debug "Checking files in #{Chef::Config[:file_backup_path]}/#{mysql_rebuild['script_dir']}/"
  #remove from backup if exists
  Dir[ "#{Chef::Config[:file_backup_path]}/#{mysql_rebuild['script_dir']}/*" ].each do |curr_path|
    if curr_path =~ /mysqldump/
      Chef::Log.debug "Removing backup file #{curr_path}"
      file curr_path do
        action :delete
        backup false
        only_if { node['mysqler']["mysql_rebuild"]['delete_rebuild_files'] == true }
      end 
    end
  end
end

