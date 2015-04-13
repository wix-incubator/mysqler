require 'digest/sha1'
 
def hash_mysql_password pass
  "*" + Digest::SHA1.hexdigest(Digest::SHA1.digest(pass)).upcase
end
