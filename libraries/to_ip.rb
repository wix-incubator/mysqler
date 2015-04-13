require 'resolv'
class String
  def to_ip
    begin
      Resolv::DNS.new.getaddress(self).to_s rescue Resolv.new.getaddress(self)
    end
  end
end
