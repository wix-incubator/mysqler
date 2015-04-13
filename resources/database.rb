actions :create, :query
default_action :create

attribute :database, kind_of: String, name_attribute: true
attribute :defaults_file, kind_of: String
attribute :host, kind_of: String
attribute :username, kind_of: String, default: 'root'
attribute :password, kind_of: String
attribute :charset, kind_of: String, default: nil
attribute :collation, kind_of: String, default: nil
attribute :query, kind_of: String, default: nil

