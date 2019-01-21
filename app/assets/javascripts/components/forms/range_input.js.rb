module Components
  module Forms
    class RangeInput < RW
      expose

      #PROPS
      #min
      #max
      #defaultValue

      def valid?
        n_prop(:model).errors[n_prop(:attr)] ? "invalid" : "valid"
      end

      def render
        t(:div, {className: 'Forms-RangeInput'},
          display_errors_if_any,
          t(:div, {className: 'input-with-field-requirement'},
            t(:input, 
              {
                className: "#{valid?}",
                type: 'range',
                'defaultValue' => "#{n_prop(:model).attributes[n_prop(:attr)]}",
                placeholder: n_prop(:show_name),
                onChange: ->{on_change},
                min: n_prop(:min),
                max: n_prop(:max),
                ref: "#{self}"
              } 
            )
          )
        )
      end

      def display_errors_if_any
        if errors = n_prop(:model).errors[n_prop(:attr)]
          t(:div, {className: 'error-messages'},
            errors.map do |er|
              t(:p, {}, er)
            end
          )
        end
      end

      def on_change
        if on_change_event = n_prop(:on_change)
          on_change_event.call
        end
        if n_prop(:collect_on_change)
          collect
        end
      end

      def collect
        p "collecting: #{ref("#{self}").value}"
        if props.record_changes
          current = props.model.attributes[props.attr]
          changed = props.model.attributes[props.attr] = ref("#{self}").value
          if current != changed
            props.model.attributes[:_changed] = true
          end
        else
          props.model.attributes[props.attr] = ref("#{self}").value
        end
      end

      def clear_inputs
        ref("#{self}").value = nil
      end

    end
  end
end

