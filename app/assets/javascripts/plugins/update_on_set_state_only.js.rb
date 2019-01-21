module Plugins
  module UpdateOnSetStateOnly
    #Including to RW component, will make it updatetable only from calling set_state on corresponding instance
    #ither way it always should_component_update == false

    def __component_did_mount__(*args)
      super *args
      @should_update = false 
    end

    def __set_state__(val)
      @should_update = true
      super val
    end

    def __component_did_update__(*args)
      super *args
      @should_update = false
    end

    def __should_component_update__(*args)
      @should_update
    end
  end
end