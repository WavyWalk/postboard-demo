module Components
  module MediaStories
    class New < RW
      expose

      include Plugins::Formable

      def validate

      end

      def get_initial_state
        media_story = MediaStory.new
        media_story.media_story_nodes << MediaStoryNode.new
        {
          media_story: media_story,
          node_offset: 0
        }        
      end

      def render
        media_story_nodes = n_state(:media_story).media_story_nodes
        p n_state(:media_story).errors

        t(:div, {className: "MediaStories-New"},
          modal,
          t(Components::MediaStories::Carousel, 
            {
              media_story_nodes: media_story_nodes,
              node_offset: n_state(:node_offset),
              on_select: event(->(index){on_node_select_to_set_in_view(index)}),
              on_add: event(->{push_new_node_to_media_nodes}),
              show_add_button: true,
              on_move_to_next_offset: event(->{move_to_next_offset(1)}),
              on_move_to_prev_offset: event(->{move_to_next_offset(-1)})
            }
          ),
          if (ers = n_state(:media_story).errors[:general]) != nil || (ners = n_state(:media_story).errors[:media_story_nodes]) != nil
            t(:div, {className: 'invalid'},
              if ers
                ers.map do |er|
                  t(:p, {}, er)
                end
              end,
              if ners
                ners.map do |er|
                  t(:p, {}, er)
                end
              end
            )
          end,
          t(:div, {className: 'g-plainTextInput'},
            input(Components::Forms::Input, n_state(:media_story), :title, {show_name: 'title', required_field: true})
          ),
          t(Components::MediaStoryNodes::New, 
            {
              media_story_node: media_story_nodes[n_state(:node_offset)],
              can_be_removed: ((n_state(:node_offset) == 0) ? false : true),
              on_remove: event(->(media_story_node){remove(media_story_node)})
            }
          ),
          t(:div, {className: 'submitBtnGroup'},
            t(:button, {className: 'submit', onClick: ->{submit} }, 'submit'),
            t(:button, {className: 'submit', onClick: ->{cancel}}, 'cancel')
          )
        )
      end

      def move_to_next_offset(value)
        new_offset = n_state(:node_offset) + value
        if n_state(:media_story).media_story_nodes[new_offset]
          set_state({node_offset: new_offset})
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

      def remove(media_story_node)
        n_state(:media_story).media_story_nodes.data.delete(media_story_node)
        set_state(
          {
            media_story: n_state(:media_story),
            node_offset: (n_state(:node_offset) - 1)
          }
        )
      end

      def submit
        collect_inputs
        n_state(:media_story).create().then do |media_story|
          begin 
          if media_story.has_errors?
            set_state media_story: media_story
          else
            p 'on_done'
            emit(:on_done, media_story)
          end
          rescue Exception => e
            p e 
          end
        end
      end

      def cancel
        emit(:on_cancel)
      end

      

    end
  end
end