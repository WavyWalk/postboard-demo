module Components
  module Forms
    class SelectFromLabels < RW
      expose

      def validate_props
        if !props.option && !props.url_feed
          puts "#{self.class.name} expects either options or url_feed"
        end
        if !props.parsing_model && props.url_feed
          puts "#{self.class.name} expects parsing_model prop when url_feed is given"
        end
        if !props.show_value
          puts "#{self.class.name} expects show_name prop"
        end
      end

      def get_initial_state
        {
          options: ModelCollection.new,
          selected: props.preselected
        }
      end

      def component_did_mount
        if props.options
          set_state options: props.options
        end

        if props.url_feed
          HTTP.get(props.url_feed).then do |response|
            begin
            _options = props.parsing_model.parse(response.json)

            state.options.data += _options.data

            set_state options: state.options
            rescue Exception => e
              p e
            end
          end
        end
      end

      def render
        t(:div, {className: 'select-from-labels'},
          t(:p, {className: 'show-name'}, 
            n_prop(:show_name),
            if props.required_field
              t(:span, {className: 'forms-requiredField'}, '*', t(:sup, {}, 'required') )
            elsif props.optional_field
              t(:span, {className: 'forms-optionalField'}, '*', t(:sup, {}, 'optional') )
            end,
          ),
          if !state.selected
            t(:div, {className: 'select-area'},
              state.options.map do |option|
                t(:div, {className: 'option', onClick: ->{select(option)}},
                  option.attributes[props.show_value]
                )
              end
            )
          end,
          if state.selected
            t(:div, {className: "selected option"},
              t(:span, {}, state.selected.attributes[props.show_value]),
              t(:span, {className: 'delete-selected', onClick: ->{deselect}}, ' X')
            )
          end
        )
      end


      def select(option)
        set_state selected: option
      end

      def deselect
        set_state selected: nil
      end

      def collect
        props.model.attributes[props.attr] = state.selected
      end



    end
  end
end
