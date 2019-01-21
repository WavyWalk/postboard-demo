module Components
  module MediaStories
    class Carousel < RW
      expose  

      def validate
        #media_story_nodes: [] of MediaStoryNode
        #node_offset: Int32 pointing to index in #media_story_nodes
        #on_select: Event(index : Int32) when user selects thumbnail, 
        #           notifies owner passing index num in media_story_nodes so it will render it as current
        #on_add: Event() when user presses add button informing owner that new MediaStoryNode should be added
        #show_add_button_flag : Bool? - flag used in render whether to show add button or not
      end

      def render
        t(:div, {className: 'MediaStories-Carousel'},
          t(:div, {className: 'navigationBtn', onClick: ->{move_to_prev_offset}},
            t(:div, {},
              '<'
            )
          ),
          n_prop(:media_story_nodes).each_with_index.map do |media_story_node, index|
            active = (n_prop(:node_offset) == index) ? "active" : ''
            t(:div, 
              {
                className: "individualThumb #{active}", 
                onClick: ->{emit(:on_select, index)}
              },
              show_thumb(media_story_node.media)
            )
          end,
          if n_prop(:hide_add_button_flag)
            t(:div, {className: 'individualThumb'},
              t(:button, {onClick: ->{emit(:on_add)}}, 'add')
            )
          end,
          t(:div, {className: 'navigationBtn', onClick: ->{move_to_next_offset}},
            t(:div, {},
              '>'
            )
          ),
        )  
      end

      def move_to_prev_offset
        emit(:on_move_to_prev_offset)
      end

      def move_to_next_offset
        emit(:on_move_to_next_offset)
      end

      def show_thumb(media)
        case media
        when PostImage        
          t(Components::PostImages::Show, {post_image: media})
        when VideoEmbed
          t(Components::VideoEmbeds::Show, {video_embed: media, no_playback: true})
        when PostGif
          t(Components::PostGifs::Show, {post_gif: media, no_playback: true})
        else
          nil
        end
      end

    end
  end
end