module Components
  module PersonalityTests
    module Personalities
      class Show < RW
        expose 
        #props
        #p_t_personality 

        def render
          p_t_personality = n_prop(:p_t_personality)
          t(:div, {className: "PersonalityTests-Personalities-Show"},
            t(:div, {className: "title"},
              t(:h3, {}, p_t_personality.title)
            ),
            t(:div, {className: "media"},
              display_media_depending_on_type
            )
          ) 
        end

        def display_media_depending_on_type
          case media = n_prop(:p_t_personality).media
          when PostImage
            t(Components::PostImages::Show, {post_image: media})
          when PostGif
            t(Components::PostGifs::Show, {post_gif: media})
          when VideoEmbed
            t(Components::VideoEmbeds::New, {video_embed: media})
          end
        end

      end
    end
  end
end
