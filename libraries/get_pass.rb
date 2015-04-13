class Chef::Recipe
  def get_pass(user)
    @passwords_db_users ||= Chef::EncryptedDataBagItem.load(node['mysqler']['passwords']['databag'], node['mysqler']['passwords']['item'])['users']
    if @passwords_db_users[user]
      @passwords_db_users[user]['password']
    else
      Chef::Log.info("No password set for user '#{user}'")
      nil 
    end
  end
end
