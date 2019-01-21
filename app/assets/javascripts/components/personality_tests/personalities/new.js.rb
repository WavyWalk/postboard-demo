module Components
  module PersonalityTests
    module Personalities
      class New < RW

        expose

        include Plugins::Formable

        def component_did_mount
          unless props.edit_mode
            n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:save_in_place)
          end
        end

        def component_will_unmount
          unless props.edit_mode
            n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:save_in_place)
          end
        end

        def render
          edit_mode = n_prop(:edit_mode) ? true : false
          new_model = n_prop(:p_t_personality).id ? false : true
          p_t_personality = n_prop(:p_t_personality)

          t(:div, {className: 'Personalities-New'},
            modal,
            t(:div, {className: 'title'},
              input(Forms::Input, p_t_personality, :title,
                {
                  required: true,
                  show_name: 'title',
                  collect_on_change: true
                }
              )
            ),
            t(:div, {className: 'media'},
              if errors = p_t_personality.errors[:media]
                t(:div, {className: 'invalid'},
                  errors.each do |error|
                    t(:p, {}, error)
                  end
                )
              end,
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
                  t(:button, {onClick: ->{init_image_addition}}, 'add image'),
                  t(:button, {onClick: ->{init_gif_addition}}, 'add gif'),
                  t(:button, {onClick: ->{init_video_embed_addition}}, 'embed video')
                )
              end
            ),
            if new_model && edit_mode
              t(:button, {onClick: ->{create_personality}}, 'save personality')
            end,
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
          force_update
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
          p 'adding gif'
          modal_close
          gif.file = `null`
          personality = n_prop(:p_t_personality)
          personality.media_id = gif.id
          personality.media_type = "PostGif"
          personality.media = gif
          force_update
        end

        def init_video_embed_addition
          modal_open(
            nil,
            t(Components::VideoEmbeds::New,
              {
                video_embed: VideoEmbed.new,
                on_done: ->(video_embed){add_video_embed(video_embed)}
              }
            )
          )
          force_update
        end

        def add_video_embed(video_embed)
          personality = n_prop(:p_t_personality)
          personality.media_type = 'VideoEmbed'
          personality.media_id = video_embed.id
          personality.media = video_embed
          modal_close
          force_update
        end

        def clear_media
          personality = n_prop(:p_t_personality)
          personality.media_type = nil
          personality.media = nil
          force_update
        end

        def handle_inputs
          collect_inputs(model: n_prop(:p_t_personality))
        end

        def create_personality
          n_prop(:p_t_personality).create.then do |p_t_personality|
            p "should emit"
            begin 
            emit(:on_p_t_personality_created, p_t_personality)
            rescue Exception => e
              p e
            end
          end
        end

        def delete
          n_prop(:owner).delete_personality(n_prop(:p_t_personality))
        end

      end
    end
  end
end
