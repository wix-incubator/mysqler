include_recipe "mysqler::install_mysql_gem"
## Manage application grants
passwords = Chef::EncryptedDataBagItem.load(node['mysqler']['passwords']['databag'], node['mysqler']['passwords']['item'])
master_pass = passwords['users'][node['mysqler']["master_user"]]['password'] || ''

# define access grants
mysqler_user node['mysqler']['master_user'] do
  defaults_file   node['mysqler']["defaults-file"]
  username        node['mysqler']['master_user'] 
  password        ''
  grant           node['mysqler']["master_user_privileges"]
  database        '*'
  tables          ["*"]
  networks        node['mysqler']["master_user_networks"] 
  user_password   master_pass
  with_grant      true
  ignore_failure  true
  action          :nothing
end

execute "check_master_user_login" do
  command "echo ' Testing #{node['mysqler']['master_user']} connection...'"
  sensitive true
  notifies :create, resources(:mysqler_user => "#{node['mysqler']['master_user']}"), :immediately
  only_if "echo 'select 1;' |  mysql --defaults-file=#{node['mysqler']["defaults-file"]} -s -u#{node['mysqler']['master_user']} > /dev/null 2>&1"
end

passwords["users"].each_pair do |user,values|
    grants = values['grants']
    if grants.kind_of?(Hash)
      grants = [grants]
    end
    grants.each do |grant|
      mysqler_user user do    
        defaults_file   node['mysqler']["defaults-file"] 
        username        node['mysqler']['master_user']
        password        master_pass
        grant           grant['actions']
        database        grant['db'] || '*'
        tables          ["*"]
        networks        values['networks'] || node['mysqler']["networks"]
        user_password   values['password']
        if grant['revoke'] # Default: create
           action  :revoke 
        end
      end
  end
end

###### build application specific users from databag
## ignore this section if databag does not exists

databag_name = node['mysqler']["users_databag_name"] rescue nil

databag_items_list = node['mysqler']['users_databag_item'] rescue nil

if databag_name and databag_items_list

  if databag_items_list.is_a? String
    databag_items_list = [databag_items_list]
  end

  databag_items_list.each do |databag_item_name|
    begin
      db_item = data_bag_item(databag_name, databag_item_name)  rescue {}

      (db_item['users']||[]).each do | user_id, db_config|
        ## support for several privilege groups
        if db_config.kind_of?(Hash)
          db_config = [db_config]
        end
        db_config.each do | db_conf |
          db_name = db_conf["db_name"] || '*'

          if db_name != '*'
            mysqler_database db_name do
              defaults_file node['mysqler']["defaults-file"]
              username      node['mysqler']["master_user"]
              charset       node['mysqler'][:tunable]['character_set_server']
              collation     node['mysqler'][:tunable]['collation_server']
              password      master_pass
              action        :create
            end
          end

          db_privileges = db_conf['privileges'] || ['USAGE']
          db_tables = db_conf['table_names'] || ['*']
          db_networks = db_conf['networks'] || node['mysqler']["networks"]
          # create user privileges
          db_privileges.each do | priv , grant|
            user = db_user(user_id,priv)
            pass = db_pass(user_id,priv)
            mysqler_user user do
              defaults_file   node['mysqler']["defaults-file"]
              username        node['mysqler']['master_user']
              password        master_pass
              grant           grant
              database        db_name
              tables          db_tables
              networks        db_networks
              user_password   pass
              action          db_conf['action'].to_sym rescue :create
            end
          end
        end
      end
    rescue Net::HTTPServerException
      log "Error building application specific privileges. Data bag not found."
    end

  end
else
  Chef::Log.info("Not processing application specific users. Check if node['mysqler']['users_databag_name'] or node['mysqler']['users_databag_item'] not set")
end

#template based grants are supported to. usually used for drops and not for grants.
template node['mysqler']["all_grants_file"] do
  source "grants.sql.erb"
  cookbook node['mysqler']["templates_cookbook"]
  owner "root"
  group "root"
  mode "0600"
end

# execute access grants
execute "mysql-install-privileges" do
  command "mysql --defaults-file=#{node['mysqler']["defaults-file"]} -f -u#{node['mysqler']["master_user"]} -p#{master_pass} < #{node['mysqler']["all_grants_file"]}"
if Gem::Version.new(Chef::VERSION) < Gem::Version.new(node['mysqler']["replace_exec_provider_before_version"])
    Chef::Log.debug("Replacing Execute provider to hide details")
    provider Chef::Provider::MyExecute
  end
  sensitive true
end

