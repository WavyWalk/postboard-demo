 module Components
  module Forms
    class FileInput < RW
      expose
      
      def __component_will_update__
        ref("#{self}").value = "" if props.reset_value == true
        super
      end

      def valid_or_not?
        props.model.errors[props.attr] ? "invalid" : "valid"
      end

      def render
        t(:div, {},
          t(:p, {}, "#{props.show_name}"),
          if errors = props.model.errors[props.attr] 
            errors.map do |er|
              t(:div, {},
                t(:p, {},
                  er
                )   
              )             
            end
          end,
          if state.uploaded
            t(:div, {},
              t(:p, {}, "selected file: #{props.model.attributes[props.attr].name}"),
              t(:button, {onClick: ->{cancel_upload}}, 'cancel')
            )
          end,
          t(:div, {},
            t(:label, {},
              if state.uploaded
                t(:button, {}, 'select another')
              else
                t(:button, {}, 'upload file')
              end, 
              t(:input, {className: "#{valid_or_not?}", ref: "#{self}", 
                         type: 'file', key: props.keyed, onChange: ->{handle_change}}),
            )
          ),
          children
        )   
      end

      def handle_change
        x = ref("#{self}").files[0]
        if x
          props.model.attributes[props.attr] = x || (puts "NO FILE"; "")
          set_state uploaded: true
        else
          props.model.attributes[props.attr] = ""
          set_state uploaded: false
        end
      end

      def collect
        props.model.attributes[props.attr] = ref("#{self}").files[0] || ""
      end

      def cancel_upload
        clear_inputs
        props.model.attributes[props.attr] = ''
        set_state uploaded: false
      end

      def clear_inputs
        ref("#{self}").value = ""
      end
    end
  end
end