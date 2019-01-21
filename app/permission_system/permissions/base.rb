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

    def initialize(model, controller, options = {})
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
