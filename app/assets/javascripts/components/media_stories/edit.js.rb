module Components
  module MediaStories
    class Edit < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          media_story: n_prop(:media_story),
          node_offset: 0,
          title_changed: false
        }
      end

      def render
        media_story_nodes = n_state(:media_story).media_story_nodes

        t(:div, {className: 'MediaStories-Edit'},  
          modal,     
          t(Components::MediaStories::Carousel, 
            {
              media_story_nodes: media_story_nodes,
              node_offset: n_state(:node_offset),
              on_select: event(->(index){on_node_select_to_set_in_view(index)}),
              on_add: event(->{push_new_node_to_media_nodes}) 
            }
          ),
          t(:div, {className: 'titleGroup'},
            input(
              Components::Forms::Input, 
              n_state(:media_story),
              :title,
              {
                show_name: 'title',
                on_change: event(->{set_title_changed}),
                namespace: 'mSTitle'
              }
            ),
            if n_state(:title_changed)
              t(:button, {onClick: ->{save_title_change}},
                'update title'
              )
            end
          ),
          t(:div, {className: 'mediaShowGroup'},
            t(Components::MediaStoryNodes::New, 
              {
                media_story_node: n_state(:media_story).media_story_nodes[n_state(:node_offset)],
                edit_mode_flag: true,
                on_remove: event(->(media_story_node){remove_media_story_node(media_story_node)})
              }
            )
          ) 
        )
      end

      def set_title_changed
        set_state(title_changed: true)
      end

      def save_title_change
        collect_inputs(namespace: 'mSTitle')
        n_state(:media_story).update.then do |media_story|
          if media_story.has_errors?
            set_state(
              media_story: n_state(:media_story)
            )
          else
            set_state(
              media_story: n_state(:media_story),
              title_changed: false
            )
          end
        end
      end

      def on_node_select_to_set_in_view(index)
        set_state(node_offset: index)
      end

      def push_new_node_to_media_nodes
        n_state(:media_story).media_story_nodes << MediaStoryNode.new(media_story_id: n_state(:media_story).id)
        set_state(
          {
            media_story: n_state(:media_story), 
            node_offset: n_state(:media_story).media_story_nodes.data.length - 1
          }
        )
      end

      def remove_media_story_node(media_story_node)
        n_state(:media_story).media_story_nodes.data.delete(media_story_node)
        set_state media_story: n_state(:media_story)
      end

    end
  end
end