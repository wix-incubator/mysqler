use_inline_resources
#require 'mysql2'

def whyrun_supported?
  true
end

def conn 
  @conn ||= begin
  Chef::Log.debug("Establishing connection to DB :default_file => #{@new_resource.defaults_file} :username => #{@new_resource.username} ")
  c = Mysql2::Client.new(
    :default_file => @new_resource.defaults_file , 
    :username => @new_resource.username, 
    :password => @new_resource.password
  )
  end
end

action :create do
  @new_resource.networks.each do | source_addr |
    @new_resource.tables.each do | table |
      sql =  "GRANT #{@new_resource.grant} ON #{@new_resource.database}.#{table} TO "
      sql += "'#{@new_resource.user}'@'#{source_addr}'"
      secure_sql = sql
      if @new_resource.user_password
        secure_sql += "  IDENTIFIED BY 'XXXXXXXXX'"
        sql += " IDENTIFIED BY '#{@new_resource.user_password}'"
      end
      if @new_resource.with_grant
        secure_sql += " WITH GRANT OPTION"
        sql += " WITH GRANT OPTION"
      end
      converge_by(secure_sql) do
        Chef::Log.debug("Running #{secure_sql}")
        results = conn.query(sql)    
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
action :revoke do
  @new_resource.networks.each do | source_addr |
    @new_resource.tables.each do | table |
      sql =  "REVOKE #{@new_resource.grant} ON #{@new_resource.database}.#{table} FROM "
      sql += "'#{@new_resource.user}'@'#{source_addr}'"
      secure_sql = sql
      converge_by(secure_sql) do
        Chef::Log.debug("Running #{secure_sql}")
        begin 
          results = conn.query(sql)  
        rescue Mysql2::Error =>  err 
          Chef::Log.debug( "Mysql REVOKE action error #{err.message}")
        end
        new_resource.updated_by_last_action(true)
      end
    end
  end
end

action :remove do
  @new_resource.networks.each do | source_addr |
    sql =  "DROP user #{@new_resource.user}'@'#{source_addr}'"
    secure_sql = sql
    converge_by(secure_sql) do
      Chef::Log.debug("Running #{secure_sql}")
      begin 
        results = conn.query(sql)  
      rescue Mysql2::Error =>  err 
        Chef::Log.debug( "Mysql REMOVE action error #{err.message}")
      end
      new_resource.updated_by_last_action(true)
    end
  end
end
