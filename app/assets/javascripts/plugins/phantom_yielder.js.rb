module Plugins

  module PhantomYielder
    def yields_phantom_ready
      Components::App::Router.phantom_instance.increment_yielders_count
    end

    def component_phantom_ready
      Components::App::Router.phantom_instance.one_component_ready
    end
  end
  
end