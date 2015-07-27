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
      end
  end
end

###### build application specific users from databag
## ignore this section if databag does not exists

databag_items = node['mysqler']["users_databag_name"] rescue ""

if databag_items.is_a? String #Only a singe name provided
  databag_items = [databag_items]
end

  databag_items.each do | databag_name |
    begin

    if databag_name.length >0 and node['mysqler']['users_databag_item']
      db_item = data_bag_item(databag_name, node['mysqler']['users_databag_item'])  rescue {}
      
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
      
          db_privileges = db_conf['privileges'] || 'USAGE'
          db_tables = db_conf['table_names'] || ['*']
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
              networks        node['mysqler']["networks"]
              user_password   pass
              action          db_conf['action'].to_sym rescue :create
            end
          end 
        end 
      end

    else
      Chef::Log.info("Not processing application specific users for #{databag_name}. Check attributes of node['mysqler']['users_databag_name'] or node['mysqler']['users_databag_item']")
    end

    rescue Net::HTTPServerException
    log "Error building application specific privileges. Data bag not found."
    end
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

