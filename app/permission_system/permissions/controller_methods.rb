module Permissions
  module ControllerMethods

    def authorize!(return_value)
      if return_value.is_a? Permissions::Base
        return_value = return_value.public_send(self.action_name)
      end
      raise Permissions::Exception unless return_value 
    end

    def build_permissions(model, options = {})
      @permission_rules = Permissions::Factory.build(model, self, options)
    end
  end
end
