class PermissionSystemInstall < Rails::Generators::Base
  
  def create_permissions_base_file
    create_file "app/permission_system/permissions/base.rb", base_class_contents
  end

  def create_permissions_factory_file
    create_file "app/permission_system/permissions/factory.rb", factory_class_contents
  end

  def create_exception_class
    create_file "app/permission_system/permissions/exception.rb", exception_class_contents
  end

  def create_controller_methods_module
    create_file "app/permission_system/permissions/controller_methods.rb", controller_methods_module_contents
  end

  def include_controller_mthods_module_in_application_controller
    inject_into_class "app/controllers/application_controller.rb", ApplicationController do
      <<-FILE

  #PERMISSION SYSTEM

  include Permissions::ControllerMethods
  
  rescue_from Permissions::Exception, with: :user_not_authorized

  def user_not_authorized
    head 403
  end

  #END PERMISSION SYSTEM
      FILE
    end
  end

  private

  def base_class_contents

    <<-'FILE'
module Permissions
  class Base

    #well this sort of Pundit, but a bit different.
    #controller has #auth!, it raises Permissions::Exception if arg is false
    #Permissions::Factory.build will prepare Permissions::#{passed model class name},
    #it implements checking methods, if no method passed will call method same as current controller action
    #also controller#perms method will call Permissions::Factory.build 
    #the idea is 
    # perm = perms(@user)
    #auth! perm (it checkes and prepares attributes and stuff)
    #@user.update(perms.permitted_attributes)
    #FUCK IM SLEEPY AND SEE ME WRITING SHIT!
    #TODO: rewrite docs

    attr_accessor :permitted_attributes, :arbitrary, :model, :serialize_on_success, :serialize_on_error

    def initialize(model, controller, options)
      @options = options
      @current_user = controller.current_user
      @controller = controller
      @model = model
      @arbitrary = {}
      @permitted_attributes = false
    end

    def params
      @controller.params
    end

  end
end
    FILE
    
  end

  def factory_class_contents
    <<-'FILE'
module Permissions
  class Factory

    def self.build(model, controller, options)

      if model.is_a? Symbol
        model_klass = model.to_s
      elsif model.respond_to?(:new)
        model_klass = model.name
      else
        model_klass = model.class.name
      end

      "Permissions::#{model_klass}Rules".constantize.new(model, controller, options)

    end

  end
end
    FILE
  end

  def controller_methods_module_contents
    <<-'FILE'
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
    FILE
  end

  def exception_class_contents
    <<-'FILE'
module Permissions
  class Exception < StandardError

    def initialize(msg = "PERMISSIONS UNATHORIZED")
      super(msg)
    end

  end
end
    FILE
  end

end