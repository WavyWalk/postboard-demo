module Components
  module Forms
    class Input < RW
      expose
      ##PROPS
      #collect_on_change : Bool? - will call collect immediately on change
      #show_name : String? - string that will act as input "placeholder"
      #model : Model - model which property will be populated from input
      #attr : String | Symbol - property name of model that will be populated
      # NOT ALL LISTED
      def __component_will_update__
        ref("#{self}").value = "" if props.reset_value == true
        super
      end

      def valid_or_not?
        props.model.errors[props.attr] ? "invalid" : "valid"
      end

      def render
        t(:div, {},
          #t(:p, {}, "#{props.show_name}"),
          if errors = n_prop(:model).errors[n_prop(:attr)]
            t(:div, {className: 'error-messages'},
              errors.map do |er|
                t(:p, {},
                  er
                )
              end
            )
          end,
          t(:div, {className: 'input-with-field-requirement'},
            if props.required_field
              t(:div, {className: 'forms-requiredField'},
                '*', t(:sup, {}, 'required')
              )
            elsif n_prop(:optional_field)
              t(:div, {className: 'forms-optionalField'},
                '*', t(:sup, {}, 'optional')
              )
            end,
            t(:input, 
              {
                className: "#{valid_or_not?}", ref: "#{self}",
                type: props.type, key: props.keyed,
                defaultValue: props.model.attributes[props.attr],
                placeholder: "#{props.show_name}",
                onChange: ->{on_change}
              }            
            )
          ),
          children
        )

      end

      def on_change
        if n_prop(:on_change)
          n_prop(:on_change).call
        end
        if n_prop(:collect_on_change)
          collect
        end
      end

      def collect
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
        ref("#{self}").value = ""
      end

    end
  end
end
