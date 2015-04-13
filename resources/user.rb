actions :create, :revoke, :remove
default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :defaults_file, kind_of: String, default: node['mysqler']["defaults-file"]
attribute :username, kind_of: String, default: node['mysqler']["master_user"]
attribute :password, kind_of: String
attribute :grant, kind_of: String, default: 'USAGE'
attribute :database, kind_of: String, default: '*'
attribute :tables, kind_of: Array, default: ['*']
attribute :networks, kind_of: Array, default: ['%']
attribute :user_password, kind_of: String
attribute :with_grant, kind_of:  [TrueClass, FalseClass], default: false

