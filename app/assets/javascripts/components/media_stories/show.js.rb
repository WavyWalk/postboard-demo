module Components
  module MediaStories
    class Show < RW
      expose

      #PROPS
      #media_story : MediaStory 
      def get_initial_state
        {
          node_offset: 0,
          blink: "blink1"
        }        
      end      

      def toggle_blink
        set_state(blink: (n_state(:blink) == "blink1" ? "blink0" : "blink1"))
      end

      def render
        t(:div, {className: 'MediaStories-Show'},
          t(:div, {className: 'title'},
            t(:h3, {},
              n_prop(:media_story).title
            )
          ),
          t(Components::MediaStories::Carousel,
            {
              media_story_nodes: n_prop(:media_story).media_story_nodes,
              node_offset: n_state(:node_offset),
              on_select: event(->(index){on_node_select_to_set_in_view(index)}),
              hide_add_button_flag: false,
              on_move_to_prev_offset: event(->{move_to_prev_offset}),
              on_move_to_next_offset: event(->{move_to_next_offset})
            }
          ),
          t(Components::MediaStoryNodes::Show,
            {
              media_story_node: n_prop(:media_story).media_story_nodes[n_state(:node_offset)],
              blink: n_state(:blink)
            }
          )
        )
      end

      def move_to_prev_offset
        node_offset = n_state(:node_offset)
        nodes_length = n_prop(:media_story).media_story_nodes.data.length 
        if node_offset == 0
          set_state(node_offset: (nodes_length - 1))
        else
          set_state(node_offset: node_offset -1)
        end 
      end

      def move_to_next_offset
        node_offset = n_state(:node_offset)
        nodes_length = n_prop(:media_story).media_story_nodes.data.length  
        if node_offset == (nodes_length - 1)
          set_state(node_offset: 0)
        else
          set_state(node_offset: node_offset + 1)
        end       
      end

      def on_node_select_to_set_in_view(index)
        set_state(node_offset: index)
      end

    end
  end
end