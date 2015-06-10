class Chef
  class Resource
    class MysqlerChefGem < Chef::Resource::ChefGem
      def initialize(name, run_context=nil)
        super
        @resource_name = :mysqler_chef_gem
        @allowed_actions.push(:pristine)
        @provider = Chef::Provider::MysqlerRubygems
      end
    end
  end
end
class Chef
  class Provider
    class MysqlerRubygems <  Chef::Provider::Package::Rubygems
      def action_pristine
        shell_out!("#{@new_resource.gem_binary} pristine \"#{@new_resource.name}\" -q ", :env=>nil)
      end 
    end
  end
end
