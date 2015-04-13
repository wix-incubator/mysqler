unless node['mysqler']['manage_users']
  Chef::Log.debug("Will not manage users. as node['mysqler'][:manage_users] is not set")
  return 
end

user = node['mysqler'][:username]
group = node['mysqler'][:usergroup]

group user do
  action :create
end

user user do
  group user
  action :create
end

if node['mysqler']["interconnect"]["databag_name"]
  interconnect = Chef::EncryptedDataBagItem.load(node['mysqler']["interconnect"]['databag_name'], 
                       node['mysqler']["interconnect"]['databag_item'] )

  interconnect['users'].each do |usr|
    if usr['action'] =="create" 

      usr['home'] ||= "/home/#{usr['id']}"
      usr['home'] ||= node['mysqler'][:usergroup]

      user usr['id'] do
        group usr['group']
        shell usr['shell']
        comment usr['comment']
        home    usr['home']
        manage_home true
      end 


      directory "#{usr['home']}/.ssh" do
        action :create
        user usr['id']
        group usr['id']
        mode 0700
      end
      file "#{usr['home']}/.ssh/id_rsa" do
        content usr['ssh_private_key']
        user usr['id']
        group usr['id']
        action :create
      end
      file "#{usr['home']}/.ssh/id_rsa.pub" do
        content usr['ssh_public_key']
        user usr['id']
        group usr['id']
        action :create
      end
      file "#{usr['home']}/.ssh/authorized_keys" do
        content usr['ssh_public_key']
        user usr['id']
        group usr['id']
        action :create
      end

    elsif usr['action'] == "remove" 
      user user['id'] do
        action :remove
      end

      file "#{usr['home']}/.ssh/id_rsa" do
        action :delete
      end
    end
  end
end
