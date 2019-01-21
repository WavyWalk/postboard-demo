module Components
  module MediaStoryNodes
    class New < RW
      expose

      include Plugins::Formable
      #PROPS
      #media_story_node : MediaStoryNode
      #edit_mode_flag : Bool?

      def validate
        #can_be_removed : Bool acts as flag to render or not the 'remove button'
        #on_remove : ProcEvent()
        unless n_prop(:media_story_node).is_a?(MediaStoryNode)
          p "#{self.class.name} invalid prop :media_story_node - expecting MediaStoryNode instance got <#{n_prop(:media_story_node)}>"
        end
      end

      def get_initial_state
        {

        }
      end

      def render
        media_story_node = n_prop(:media_story_node)

        t(:div, {className: "MediaStoryNodes-New"},
          modal,
          t(:div, {className: 'mediaShow'},
            if ers = n_prop(:media_story_node).errors[:media]
              t(:div, {className: 'invalid'},
                ers.map do |er|
                  t(:p, {},
                    er
                  )
                end
              )
            end,
            t(:div, {className: ''},
              if n_prop(:media_story_node).media
                t(:button, {onClick: ->{clear_media}}, 'clear')
              end,
              if n_prop(:can_be_removed)
                t(:div, {className: 'removeBtn', onClick: ->{delete_this}},
                  t(:button, {}, 'delete this slide')
                )
              end
            ),
            show_node_depending_on_type
          ),
          t(:div, {className: 'annotationInput'},
            t(:p, {className: 'inputAnnotation'}, 'add annotation'),
            t(:div, {key: n_prop(:node_offset)},
              input(Components::Forms::WysiTextarea, media_story_node, :annotation, 
                    {
                      collect_on_change: true
                    }
              )
            )
          ),
          if n_prop(:edit_mode_flag)
            button_text = n_prop(:media_story_node).id ? "save changes" : "create slide"
            t(:button, {onClick: ->{submit_when_in_editing_mode}}, button_text)
          end
        )
      end

      def show_node_depending_on_type
        case media = n_prop(:media_story_node).media
        when PostImage        
          t(Components::PostImages::Show, {post_image: media})
        when VideoEmbed
          t(Components::VideoEmbeds::New, {video_embed: media, key: "#{media}"})
        when PostGif
          t(Components::PostGifs::Show, {post_gif: media})
        else
          add_media_button
        end
      end

      def add_media_button
        t(:div, {className: 'addNode'},
          t(:button, {onClick: ->{init_image_addition}}, 'add image'),
          t(:button, {onClick: ->{init_gif_addition}}, 'add gif'),
          t(:button, {onClick: ->{init_video_embed_addition}}, 'embed video')
        )
      end

      def init_image_addition
        modal_open(
          nil,
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_image(image)}),
              post_images: []
            } 
          )
        )
      end 

      def insert_image(image)
        n_prop(:media_story_node).media = image
        n_prop(:media_story_node).media_type = 'PostImage'
        modal_close
        force_update
      end

      def init_gif_addition
        modal_open( 
          nil, 
          t(Components::PostGifs::New, 
            {
              on_post_gif_uploaded: event(->(post_gif){open_modal_for_post_gif_to_edit_its_subtitles(post_gif)}) 
            }
          )
        )
      end

      def open_modal_for_post_gif_to_edit_its_subtitles(post_gif)
        modal_close
        modal_open(
          nil,
          t(:div, {},
            t(:p, {}, "Your gif has been uploaded."),
            t(:p, {}, "want to add subtitles, or funny stuff to gif?"),
            t(:button, { onClick: ->{open_modal_for_subtitle_insertion_for_gif(post_gif)} }, "yeah!"),
            t(:button, { onClck: ->{ insert_gif_component(post_gif) } }, "nope")
          )
        )
      end

      def open_modal_for_subtitle_insertion_for_gif(post_gif)
        modal_close
        modal_open(
          nil,
          t(Components::Subtitles::New, {
            post_gif: post_gif,
            on_completed: ->(post_gif){insert_gif_component(post_gif)}
          })
        )
      end

      def  insert_gif_component(post_gif)
        n_prop(:media_story_node).media = post_gif
        n_prop(:media_story_node).media_type = 'PostGif'
        force_update
      end

      def init_video_embed_addition
        n_prop(:media_story_node).media = VideoEmbed.new
        n_prop(:media_story_node).media_type = 'VideoEmbed'
        force_update       
      end

      def clear_media
        n_prop(:media_story_node).media = nil
        n_prop(:media_story_node).media_type = nil
        n_prop(:media_story_node).media_id = nil
        force_update
      end

      def submit_when_in_editing_mode
        collect_inputs
        if n_prop(:media_story_node).id
          update_existing_media_story_node
        else
          create_media_story_node
        end
      end

      def update_existing_media_story_node
        n_prop(:media_story_node).update().then do |media_story_node|
          if media_story_node.has_errors?
            force_update
          else
            alert('updated successfully')
            force_update
          end
        end
      end

      def create_media_story_node
        n_prop(:media_story_node).create.then do |media_story_node|
          if media_story_node.has_errors?
            force_update
          else
            alert('created successfully')
            force_update
          end
        end
      end

      def delete_this
        if n_prop(:media_story_node).id
          n_prop(:media_story_node).destroy.then do |media_story_node|
            if media_story_node.has_errors?
              n_prop(:media_story_node).errors = media_story_node.errors
              force_update
            else
              emit(:on_remove, n_prop(:media_story_node))
            end
          end
        else
          emit(:on_remove, n_prop(:media_story_node))
        end
      end

    end
  end
end