module Components
  module Forms
    class PlainCheckbox < RW
      expose

      def render
        t(:div, {},

        )
      end

      def valid_or_not?
        if props.model.errors[:attr]
          "invalid"
        else
          "valid"
        end
      end

      def get_initial_state
        {
          checked: props.checked,
          check_value: props.check_value ? props.check_value : "1"
        }
      end

      def options
        opts = {}
        state.checked ? (opts[:checked] = "checked") : nil
        opts
      end

      def render
        t(:div, {},
          if props.model.errors[props.attr]
            (props.model.errors[props.attr] ||= []).map do |er|
              t(:div, {className: 'errors'},
                t(:p, {},
                  er
                ),
                t(:br, {})
              )
            end
          end,
          t(:input, 
            {
              type: "checkbox",
              key: props.keyed, onChange: ->{check}
            }.merge(options)
          ),
          t(:p, {className: 'show_name'}, "#{props.show_name}"),
          children
        )
      end


      def check
        set_state checked: !state.checked
        if props.to_call_on_change
          emit(:to_call_on_change)
        end
      end

      def collect
        props.model.attributes[props.attr] = state.checked ? state.check_value : ""
      end

      def clear_inputs
        ref("#{self}").value = ""
      end


    end
  end
end
