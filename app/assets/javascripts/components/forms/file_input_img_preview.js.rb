module Components
  module Forms
    class FileInputImgPreview < RW
      expose

      #PROPS
      # OPTIONAL
      # :reset_on_collect : Boolean -> necessary if you want to reset preview if
      # use one input to feed multiple uploads (implementation of usage is up to you)

      #after collected props.attr assigned to string representation of file.
      #But if errors returned from server, previewed image and e.g. name of file can't be gotten from that string (without reparsing as file)
      #so this accessor keeps the last assigned file, and combined with should_assign_self_to_owner prop,
      #owner can access it and assign on model being passed, e/g/ restore the state
      #THIS IS A DIRTY HACK SHOULD REFACTOR ON MODEL LEVEL.
      attr_accessor :preserved_file

      def __component_will_update__
        ref("#{self}").value = "" if props.reset_value == true
        super
      end

      def component_will_receive_props(next_props)
        next_props = Native(next_props)
        if x = next_props.model.errors[props.attr]
          set_state errors: x, uploaded: false, image_to_preview: false
        else
          set_state errors: false
        end
      end

      def valid_or_not?
        props.model.errors[props.attr] ? "invalid" : "valid"
      end

      def get_initial_state
        if n_prop(:should_assign_self_to_owner)
          n_prop(:owner).set_image_input_component(self)
        end
        {
          counter: 0, #this needed because of weird bug of not rendering errors
          errors: false,
          image_to_preview: false,
          #should_preview: (n_prop(:should_preview) || false)
        }
      end

      def preview_image(file = nil)
        file  ||= ref("#{self}").files[0]
        `
        var file = #{file.to_n};
        var reader  = new FileReader();

        reader.onloadend = function () {
          #{set_state image_to_preview: `reader.result`};
        }

        if (file) {
          reader.readAsDataURL(file);
        } else {
          #{set_state image_to_preview: false};
        }
        `
      end



      def render
        t(:div, {className: "#{valid_or_not?} file-input-image-preview"},
          t(:div, {key: state.counter},
            if state.errors
              state.errors.map do |er|
                t(:p, {}, "#{er}")
              end
            end
          ),
          if state.uploaded
            t(:div, {},
              t(:p, {}, "selected file: #{props.model.attributes[props.attr].name}"),
              t(:button, { className: 'btn btn-sm btn-danger', onClick: ->{cancel_upload} }, 'cancel')
            )
          end,

          t(:div, {className: 'g-with-bottom-divider'},
            t(:div, {className: 'label_holder'},
              t(:form, {ref: "form#{self}"},
                t(:label, {className: 'file_input_container'},
                if state.uploaded
                  t(:button, {className: 'upload_button btn btn-sm btn-dafault'}, 'select another')
                else
                  t(:button, {className: 'upload_button btn btn-sm btn-default'}, 'choose image to upload')
                end,

                  t(:input, {id: "#{self}fileinput", name: "#{self}fileinput", className: "#{valid_or_not?} fileinput", ref: "#{self}",
                           type: 'file', key: props.keyed, onChange: ->{handle_change} })
                )
              )
            ),
            unless state.uploaded
              [
              t(:p, {className: 'or'}, 'or'),
              t(:div, {className: 'input-and-button'},
                t(:input, {placeholder: "paste link to image", ref: "upload_by_url_input"}),
                t(:button, {className: 'btn btn-default', onClick: ->{parse_image_by_url}},
                  "ok"
                )
              )
              ]
            end
          ),

          # t(:div, {},
          #   t(:span, {}, 'preview before uploading  '),
          #   t(:input, {type: 'checkbox', checked: n_state(:should_preview), onChange: ->{set_state should_preview: !n_state(:should_preview)}})
          # ),
          if state.image_to_preview
            t(:div, {},
              t(:p, {}, 'this image will be uploaded'),
              t(:div, {className: 'preview-area'},
                t(:img, {src: state.image_to_preview, alt: "preview-image" })
              ),
              t(:div, {className: 'controll-buttons'},
                if n_prop(:actions_on_preview_image)
                  n_prop(:actions_on_preview_image).map do |action|
                    t(:button, {className: 'btn btn-sm btn-primary', onClick: ->{action[:event].call(self)}}, action[:button_text])
                  end
                end
              )
              # if n_prop(:action_on_preview_image)
              #   t(:button, {onClick: ->{emit(:action_on_preview_image, self)}}, n_prop(:button_content_for_action_on_preview_image))
              # end
            )
          end
        )
      end

      def parse_image_by_url
        image_url = `#{n_ref('upload_by_url_input')}.value`
        PostImage.create_from_url(extra_params: {url: image_url}).then do |attributes|
          begin
          url = attributes['post_size_url']
          `
            var image = new Image();
            image.onload = function(){
              var canvas = document.createElement('canvas');
              canvas.width = image.width;
              canvas.height = image.height;
              var ctx = canvas.getContext('2d');
              ctx.drawImage(image, 0,0);
              var dataUrl = canvas.toDataURL();

              var blob = #{Services::JsHelpers.data_url_to_blob(`dataUrl`)}
              var file = new File([blob], "from_url.jpg", {type: 'image/png'})
              #{handle_change(Native(`file`))}
            }
            image.src = #{url}
          `
          recue Exception => e
            p e
          end
        end
      end

      def handle_change(file = nil)
        emit(:on_file_chosen_by_user) if n_prop(:on_file_chosen_by_user)
        file ||= ref("#{self}").files[0]
        if file
          props.model.attributes[props.attr] = file || ""
          set_state uploaded: true
          emit(:image_preload_status, true)
        else
          props.model.attributes[props.attr] = ""
          set_state uploaded: false
          emit(:image_preload_status, true)
        end
        preview_image(file)
      end

      def collect
        #file = nil
        `
        //var blobBin = atob(#{n_state(:image_to_preview)}.split(',')[1]);
        //var array = [];
        //for(var i = 0; i < blobBin.length; i++) {
        //    array.push(blobBin.charCodeAt(i));
        //}
        //blob = new Blob([new Uint8Array(array)], {type: 'image/png'});
        //#{file} = new File([blob], 'memified.jpg', {type: 'image/png'});
        `

        #from src base64, for cases only when memed
        #TODO: read from file input and pass as file if not memed
        file = n_state(:image_to_preview)
        #case of errors so that image would be still previvable
        #if errors this will get assigned to image as file
        @preserved_file = props.model.attributes[props.attr]
        props.model.attributes[props.attr] = file || ""#ref("#{self}").files[0] || ""

      end

      def clear_inputs_and_previewed_image
        clear_inputs
        set_state uploaded: false, image_to_preview: false
      end

      def cancel_upload
        emit(:on_cancel_upload) if n_prop(:on_cancel_upload)
        clear_inputs
        props.model.attributes[props.attr] = ''
      end

      def clear_inputs
        #previously: was ref("#{self}").value = ""
        #WATCH OUT IN IE, somehow it breaks the collected value (after it was collected, (maybe it'd be passed by pointer idk)),
        #if setting input to ""
        n_ref("form#{self}").JS.reset()
        set_state uploaded: false, image_to_preview: false
        emit(:image_preload_status, false)
      end

    end
  end
end
