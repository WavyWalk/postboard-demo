module Components
  module Forms
  	class WysiTextarea < RW
  		expose

      #PROPS
      #collect_on_change : Bool? - will call collect immediately on change
      #show_name : String? - string that will act as input "placeholder"
      #model : Model - model which property will be populated from input
      #attr : String | Symbol - property name of model that will be populated

      def valid_or_not?
        props.model.errors[props.attr] ? "invalid" : "valid"
      end

  		def render
        t(:div, {className: 'input-wysi'},
          modal,
          t(:p, {className: 'show-name'}, props.show_name),
          if x = props.model.errors[props.attr]
            t(:div, {className: 'invalid'},
              x.map do |er|
                t(:p, {},
                  er
                )
              end
            )
          end,
  				t(:div, {id: "wysi_toolbar#{self.unique_name}", style: {display: "none"}.to_n},
            if n_prop(:allow_media_insert)
              t(:div, {className: 'controll-buttons'},
                t(:button, { className: "btn btn-primary", onClick: ->{init_image_insertion} }, 'insert image')
              )
            end
          ),
  				t(:div, {id: "wysi#{self.unique_name}", dangerouslySetInnerHTML: {__html: props.model.attributes[props.attr]}.to_n, onBlur: ->(e){handle_blur(e)} })
  			)
  		end

  		def component_will_unmount
  			@wysi_editor.destroy
  		end

  		def component_did_mount
        parse_rules = n_prop(:parse_rules) ? n_prop(:parse_rules) : `wysihtml5ParserRules`

        wysi_elem = "wysi#{self.unique_name}"
        wysi_toolbar_elem = "wysi_toolbar#{self.unique_name}"
  			@wysi_editor = Native(%x{
  				new wysihtml5.Editor(
            #{wysi_elem},
            {
    				  toolbar: #{wysi_toolbar_elem},
              parserRules: #{parse_rules},
              useLineBreaks: false
    				},
            function(){
              console.log("wysiLoaded");
            }
          )
  			})



        `
        #{@wysi_editor.to_n}.on(
          "load",
          function(){

            if (#{n_prop(:focus_on_load)}) {
              #{@wysi_editor.to_n}.focus();
            };

            if (#{n_prop(:collect_on_change)} || #{n_prop(:on_change)}) {
              $(#{@wysi_editor.to_n}.editableElement).on(
                "keydown.wysi_event",
                function(){
                  if (#{n_prop(:collect_on_change)}) {
                    #{self.collect};
                  }
                  if (#{n_prop(:on_change)}) {
                    #{n_prop(:on_change).call}
                  }
                }
              )
            }

          }
        );
        `

  		end

    #IMAGE COMPONENT INSERTION NOT USED CONSIDER DELETING
      def init_image_insertion
        if book_mark_not_set?
          alert 'click on textarea where you want to put your image, and then click here'
          return
        else
          modal_open(
            nil,
            modal_content_for_image_insert
          )
        end
      end

      def modal_head_for_image_insert
        t(:p, {}, 'upload image and select it')
      end

      def modal_content_for_image_insert
        t(:div, {},
          t(Components::PostImages::New,
            {
              on_image_uploaded: event(->(image){insert_image_component(image)})
            }
          )
        )
      end

      def insert_image_component(post_image)
        set_bookmark
        @wysi_editor.composer.commands.exec(
          "insertHTML",
          "<img src=\"#{post_image.post_size_url}\" imageId=\"#{post_image.id}\">"
        )
        modal_close
      end
    #END IMAGE COMPONENT INSERTION
      def bookmark
        @bookmark = @wysi_editor.composer.selection.getBookmark()
      end

      def book_mark_not_set?
        if bookmark == 0
          true
        end
      end

      #SET BOOK SHALL BE USED IN SITUATIONS like:
      #when you click non standart things from toolbar, like custom uploader and etc. the editor will blur and loose caret position
      #so you will be unable to return there, so in handler before blur occurs it calls #bookmark which sets caret position and selection
      #then you perform your operation and when you need to insert anything you just call #set_bookmark which will restore before blur state
      #and you can use it like set_bookmark; x = get_some_selection; insert_at_some_selection(x)
      def set_bookmark
        @wysi_editor.composer.selection.setBookmark(@bookmark)
      end

      def handle_blur(e)
        bookmark
      end

      def collect
        if props.record_changes
          current = props.model.attributes[props.attr]
          changed = props.model.attributes[props.attr] = @wysi_editor.getValue
          if current != changed
            props.model.attributes[:_changed] = true
          end
        else
          props.model.attributes[props.attr] = @wysi_editor.getValue
        end
      end

      def clear_inputs
        @wysi_editor.clear()
      end

  	end
  end
end
