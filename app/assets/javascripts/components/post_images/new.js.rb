module Components
  module PostImages
    class New < RW
      expose
      #
      # PROPS
      # accepted props
      #         OPTIONAL
      # on_image_uploaded : ProcEvent event that accepts arg
      # (image : PostImage) - shall be called
      # when image successfully uploaded to inform parent component.
      # on_file_chosen_by_user - ProcEvent will fire when user clicked ok on native popup
      # on_cancel_upload - ProcEvent will fire when user clicked cancel updload

      def validate_props
        if x = n_prop(:on_image_uploaded)
          if !x.is_a?(ProcEvent)
            puts "#{self} of #{self.class} - :on_image_uploaded optional prop was
                  passed, that should be of ProcEvent instance, but was not
                  got #{props.on_image_uploaded.class} instead"
          end
        end
      end

      #needed to not flush the file, and assign previewed image as file if errors are returned from backend
      def set_image_input_component(component)
        @image_input_component = component
      end

      include Plugins::Formable

      def get_initial_state
        {
          post_image: PostImage.new,
          image_preload_status: false,
          loads_by_url: false
        }
      end

      def render
        p "post_image: #{n_state(:post_image)}"
        p "post_image: #{n_state(:post_image).errors}" 
        t(:div, {className: 'images-new'},
          modal,
          progress_bar,
          general_errors_for(n_state(:post_image)),
          input(Components::Forms::FileInputImgPreview, state.post_image, :file, {
            show_name: 'image',
            reset_on_collect: true,
            image_preload_status: event(->(status){set_state(image_preload_status: status)}),
            should_assign_self_to_owner: true,
            owner: self,
            actions_on_preview_image: [
              {
                event: ->(input_component){init_meme_generator(input_component)},
                button_text: 'edit: make meme'
              },
              {
                event: ->(input_component){init_collage_generator(input_component)},
                button_text: 'edit: make collage'
              }
            ],
            button_content_for_action_on_preview_image: 'make meme out of this image',
            on_file_chosen_by_user: n_prop(:on_file_chosen_by_user),
            on_cancel_upload: n_prop(:on_cancel_upload)
          }),
          unless n_prop(:hide_alt_text)
            [
              input(Components::Forms::Input, n_state(:post_image), :alt_text, {show_name: 'describe image in text', required_field: true}),
              input(Components::Forms::Input, n_state(:post_image), :source_name, {show_name: 'where did you get image'}),
            ]
          end,
          #input(Components::Forms::Input, n_state(:post_image), :source_link, {show_name: 'image link'}),
          if n_state(:image_preload_status)
            t(:button, { onClick: ->{handle_inputs}, className: 'btn btn-xs submit-btn' }, 'upload image')
          end
        )
      end

      def init_meme_generator(input_component)
        modal_open(
          nil,
          t(Components::PostImages::MemeGenerator, {
            image_src: input_component.n_state(:image_to_preview),
            on_done: ->(image_src){ modal_close ; input_component.set_state(image_to_preview: image_src) }
          })
        )
      end

      def init_collage_generator(input_component)
        modal_open(
          nil,
          t(Components::PostImages::CollageNew, {
            image_src: input_component.n_state(:image_to_preview),
            on_done: ->(image_src){ modal_close ; input_component.set_state(image_to_preview: image_src) }
          })
        )
      end

      def handle_upload_by_url_input_change

      end

      def handle_inputs
        collect_inputs(form_model: :post_image)
        if state.post_image.has_errors?

          set_state post_image: state.post_image

        else
          #for cases when this component acts as proxy, without creating image component
          #it simply will yield serialized file through event
          #example usage, user has avatar file field, but making extra component for it's upload is tedious, therefore
          #this component is used like proxy
          if n_prop(:acts_as_proxy)
            @image_input_component.clear_inputs_and_previewed_image
            emit(:on_image_selected, n_state(:post_image).file)
          elsif n_prop(:on_collect)
            n_prop(:on_collect).call(n_state(:post_image), self)            
          else
            state.post_image.create(component: self).then do |_post_image|
              begin
              if _post_image.has_errors?
                update_when_has_errors
              else
                @image_input_component.clear_inputs_and_previewed_image
                perform_action_on_image_upload(_post_image)
              end
              rescue Exception => e
                `console.log(#{e})`
              end
            end
          end

        end

      rescue Exception => e
        `console.log(#{e})`
      end

      def update_when_has_errors
        state.post_image.file = @image_input_component.preserved_file
        set_state post_image: state.post_image
      end


      def perform_action_on_image_upload(image)

        emit(:on_image_uploaded, image)
        set_state post_image: PostImage.new

      end



    end
  end
end
