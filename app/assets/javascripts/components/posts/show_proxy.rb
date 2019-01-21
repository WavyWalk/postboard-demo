module Components
  module Posts
    class ShowProxy < RW

      expose

      def init
        if (props.location.pathname == "/dashboard/#{props.params.user_id}/posts/index/#{props.params.post_id}")
          @source_class = Components::Users::Posts::Index
        elsif (props.location.pathname == "/users/#{props.params.user_id}/posts/#{props.params.post_id}")
          @source_class = Components::Users::Posts::Index
        else
          @source_class = Components::Posts::Index
        end
        unless n_prop(:owner)
          props.owner = @source_class.instance
        end
      end

      def component_did_mount
        modal_open(nil ,content)
      end

      def method_name
        modal_open(nil ,content)
      end

      def component_will_receive_props(np)
        modal_open(nil ,content)
      end

      def render
        modal({className: 'modal-fullscreen', on_user_intentional_close: ProcEvent.new(->{push_history_one_level_back})})
      end

      def push_history_one_level_back
        full_path = props.location.pathname.split('/')
        full_path.pop
        full_path = full_path.join('/')
        props.history.push(full_path)
      end

      def content
        t(Components::Posts::Show, 
          {
            owner: n_prop(:owner), 
            params: props.params, 
            source_class: @source_class, 
            location: props.location
          }
        )
      end

    end
  end
end
