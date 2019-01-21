module Components
  module Shared
    class LoadIconPool < RW
      expose

      def self.instance
        @@instance
      end

      def init
        @last_x = 0
        @last_y = 0
      end

      def create_load_icon(component)
        icons = n_state(:active_icons)
        icons[component] = t(Components::Shared::LoadIcon, {x: @last_x, y: @last_y}) 
        set_state active_icons: icons
      end

      def destroy_load_icon(component)
        icons = n_state(:active_icons)
        icons.delete(component)
        set_state active_icons: icons
      end

      def get_initial_state
        @@instance = self
        {
          active_icons: {}
        }
      end

      def component_did_mount
        `
          $('#app').on(
            'click.loadIcon', 
            function(e){
              console.log("clicked")
              #{
                @last_x = `e.pageX`
                @last_y = `e.pageY`
              }

            }
          )
        `
      end


      def component_will_unmount
        @@instance = nil
        `
          $("#app").off("click.loadIcon")
        `
      end


      def render
        t(:div, {id: 'load-icon-pool'},
          n_state(:active_icons).values
        )
      end

    end


    class LoadIcon < RW
      expose

      def render
        t(:div, {className: 'load-icon', style: `{top: #{n_prop(:y)}, left: #{n_prop(:x)}}`})
      end

    end
  end
end