use_inline_resources 
#require 'mysql2'

def whyrun_supported?
  true
end

def conn 
  @conn ||= begin
    if @new_resource.defaults_file
      Chef::Log.debug("Establishing connection to DB :default_file => #{@new_resource.defaults_file} :username => #{@new_resource.username}")
      c = Mysql2::Client.new(
        :default_file => @new_resource.defaults_file , 
        :username => @new_resource.username, 
        :password => @new_resource.password
      )
    else
      Chef::Log.debug("Establishing connection to DB :host => #{@new_resource.host} :username => #{@new_resource.username}")
      c = Mysql2::Client.new(
        :host => @new_resource.host ,
        :username => @new_resource.username,
        :password => @new_resource.password
      )
    end
  end
end

action :query do
  sql = @new_resource.query
  converge_by(sql) do
    results = conn.query(sql)    
    results.each do | res |
        row = res.inspect
        Chef::Log.debug("Query result #{row}")
    end
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  sql = "CREATE DATABASE IF NOT EXISTS #{@new_resource.name}"
  if @new_resource.charset
    sql += " DEFAULT CHARACTER SET #{@new_resource.charset}"
  end
  if @new_resource.collation
    sql += " DEFAULT COLLATE #{@new_resource.collation}"
  end
  converge_by(sql) do
    results = conn.query(sql)    
    if Chef::Log.level==:debug
      results = conn.query("show create database #{@new_resource.name}")
      results.each do | res |
        Chef::Log.debug(res.inspect)
      end
    end
    new_resource.updated_by_last_action(true)
  end
end
