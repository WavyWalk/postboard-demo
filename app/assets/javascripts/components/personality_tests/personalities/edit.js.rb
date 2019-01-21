module Components
  module PersonalityTests
    module Personalities
      class Edit < RW

        expose

        include Plugins::Formable

        def get_initial_state
          {
            title_changed: false
          }
        end

        def render
          p_t_personality = n_prop(:p_t_personality)

          t(:div, {className: 'Personalities-New'},
            modal,
            t(:div, {className: 'title'},
              input(Forms::Input, p_t_personality, :title,
                {
                  required: true,
                  show_name: 'title',
                  collect_on_change: true,
                  on_change: ->{set_title_changed}
                }
              )
            ),
            if n_state(:title_changed)
              t(:button, {onClick: ->{update_title}}, 'update title')
            end,
            t(:div, {className: 'media'},
              if p_t_personality.media
                [
                  display_media,
                  t(:div, {className: 'g-btn-group'},
                    t(:button, {className: 'btn btn-xs', onClick: ->{clear_media}},
                      'remove media'
                    )
                  )
                ]
              else
                t(:div, {},
                  t(:div, {className: 'invalid'}, 'please provide media'),
                  t(:button, {onClick: ->{init_image_addition}}, 'add image'),
                  t(:button, {onClick: ->{init_gif_addition}}, 'add gif'),
                  t(:button, {onClick: ->{init_video_embed_addition}}, 'embed video')
                )
              end
            ),
            t(:button, {onClick: ->{delete}},
              'remove this personality'
            )
          )
        end

        def display_media
          case media = n_prop(:p_t_personality).media
          when PostImage
            t(Components::PostImages::Show, {post_image: media})
          when PostGif
            t(Components::PostGifs::Show, {post_gif: media})
          when VideoEmbed
            t(Components::VideoEmbeds::Show, {video_embed: media})
          end
        end

        def init_image_addition
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview,
              {
                on_image_selected: event(->(image){add_image(image)}),
                post_images: []
              }
            )
          )
        end

        def add_image(image)
          personality = n_prop(:p_t_personality)
          personality.media_id = image.id
          personality.media_type = "PostImage"
          personality.media = image
          modal_close
          update_media
        end

        def init_gif_addition
          modal_open(
            nil,
            t(:div, {},
              t(Components::PostGifs::New,
                {
                  on_done: event(->(post_gif){add_gif(post_gif)}),
                  subtitles_allowed: true
                }
              )
            )
          )
        end

        def add_gif(gif)
          personality = n_prop(:p_t_personality)
          personality.media_id = gif.id
          personality.media_type = "PostGif"
          modal_close
          update_media
        end

        def init_video_embed_addition
          personality = n_prop(:p_t_personality)
          personality.media_type = "VideoEmbed"
          personality.media = VideoEmbed.new
          modal_open(
            nil,
            t(Components::VideoEmbeds::New,
              {
                video_embed: personality.media,
                on_uploaded: ->(video_embed){add_video_embed(video_embed)}
              }
            )
          )
          force_update
        end

        def add_video_embed(video_embed)
          n_prop(:p_t_personality).video_embed = video_embed
          force_update
        end

        def clear_media
          personality = n_prop(:p_t_personality)
          personality.media_type = nil
          personality.media = nil
          force_update
        end

        def delete
          n_prop(:p_t_personality).destroy.then do |p_t_personality|
            p_t_personality.validate
            if p_t_personality.has_errors?
              force_update
            else
              emit(:on_delete, p_t_personality)
            end
          end
        end


        def set_title_changed
          set_state(title_changed: true)
        end

        def update_title
          n_prop(:p_t_personality).update.then do |p_t_personality|
            if p_t_personality.has_errors?
              force_update
            else
              set_state(title_changed: false)
              n_prop(:owner).force_update
            end
          end
        end

        def update_media
          n_prop(:p_t_personality).medias_update.then do |p_t_personality|
            force_update
          end
        end

      end
    end
  end
end
