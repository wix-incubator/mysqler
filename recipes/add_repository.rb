include_recipe 'apt'

apt_repository node['mysqler'][:mysql_repo_name]  do
  uri          node['mysqler'][:mysql_repo_uri]
  distribution node['lsb']['codename']
  components   node['mysqler'][:mysql_repo_components]
  key          node['mysqler'][:mysql_repo_key]
  keyserver    node['mysqler'][:mysql_repo_keyserver]
  only_if      { node['mysqler'][:add_mysql_repo] == true }
  action        :nothing
end.run_action(:add)

apt_preference node['mysqler'][:mysql_repo_name] do
  glob          node['mysqler'][:mysql_repo_glob]
  pin           node['mysqler'][:mysql_repo_pin] 
  pin_priority  node['mysqler'][:mysql_repo_pin_priority]
  only_if       { node['mysqler'][:add_mysql_repo] == true and node['mysqler'][:add_mysql_repo_preference] == true}
  action        :nothing
  notifies      :run, 'execute[apt-get update]', :immediately
end.run_action(:add)
