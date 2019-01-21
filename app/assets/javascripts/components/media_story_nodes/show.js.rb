module Components
  module MediaStoryNodes
    class Show < RW
      expose

      #PROPS
      #media_story_node : MediaStoryNode
      #blink: String - blink1 blink2 

      def render
        t(:div, {className: "MediaStoryNodes-Show #{n_prop(:blink)}"},
          t(:div, {className: 'mediaContent'},
            show_node_depending_on_type
          ),
          t(:div, 
            {
              className: 'annotation', 
              dangerouslySetInnerHTML: {__html: n_prop(:media_story_node).annotation}.to_n
            }
          )
        )
      end

      def show_node_depending_on_type
        case media = n_prop(:media_story_node).media
        when PostImage        
          t(Components::PostImages::Show, {post_image: media})
        when VideoEmbed
          t(Components::VideoEmbeds::Show, {video_embed: media})
        when PostGif
          t(Components::PostGifs::Show, {post_gif: media})
        end
      end

    end
  end
end