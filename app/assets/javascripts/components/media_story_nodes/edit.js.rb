module Components
  module MediaStoryNodes
    class Edit < RW
      expose

      def get_initial_state
        {
          media_story_node: n_prop(:media_story_node)
        }
      end

      def render
        t(:div, {className: 'MediaStoryNodes Edit'},
          
        ) 
      end

    end
  end
end