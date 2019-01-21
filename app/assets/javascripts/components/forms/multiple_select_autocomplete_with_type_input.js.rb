module Components
  module Forms
    class MultipleSelectAutocompleWithTypeInput < RW

      expose

      #PROPS
      #autocomplete_url : String
      #class_name : String | Symbol name of Model
      #show_attribtue : String | Symbol representing attribute on model that will be used for displayiung

      #optional:
      # preselected : Modelcollection , preselected

      def get_initial_state

        prepare_initial_state

        {
          parsing_model: Model.model_registry[props.parsing_model],
          autocomplete_url: props.autocomplete_url,

          selected: @selected,
          options: ModelCollection.new,
          show_attribute: props.show_attribute
        }

      end

      def prepare_initial_state

        selected_passed_as_prop?

      end

      def selected_passed_as_prop?
        if props.preselected
          (@selected = ModelCollection.new).data += props.preselected.data
        else
          @selected = ModelCollection.new
        end
      end

      def render
        t(:div, {className: 'multiple-select'},
          t(:p, {}, 
            'you can add tags that you think best describe your post', 
            if props.required_field
              t(:span, {className: 'forms-requiredField'}, '*', t(:sup, {}, 'required') )
            elsif props.optional_field
              t(:span, {className: 'forms-optionalField'}, '*', t(:sup, {}, 'optional') )
            end,
          ), 
          
          t(:div, {className: 'selected'},
            state.selected.map do |model|
              next if props.mark_for_destruction && model.attributes[props.mark_for_destruction]
              t(:span, { className: 'selected-item', onClick: ->{ remove(model)} }, model.attributes[state.show_attribute], " X")
            end
          ),
          t(:div, { className: 'input-group', onChange: ->(e){handle_input_change(e)} },
            t(:input, {placeholder: 'start typing', type: 'text', ref: 'temporary_input', onKeyPress: ->(e){enter_pressed_on_input(Native(e))} },

            ),
            t(:button, { onClick: ->(){add_typed()} },
              'add'
            )
          ),
          if state.options.data.length > 0
            t(:div, {className: 'drop-down'},
              state.options.map do |model|
                t(:p, {onClick: ->{add(model)}}, model.attributes[state.show_attribute])
              end
            )
          end
        )
      end


      def add_typed
        whats_typed = (temporary_input = ref(:temporary_input).value)
        to_add = state.parsing_model.new(state.show_attribute => whats_typed)
        state.selected << to_add
        state.options.data = []
        set_state selected: state.selected, options: state.options
        ref(:temporary_input).value = ''
      end


      def remove(model)
        if props.mark_for_destruction && model.id
          model.attributes[props.mark_for_destruction] = true
          set_state selected: state.selected
        else
          state.selected.remove(model)
          set_state selected: state.selected
        end
      end

      def enter_pressed_on_input(e)
        key = e.which
        if key == 13
          add_typed
        end
      end

      def add(model)
        ref(:temporary_input).value = ""
        state.options.data = []
        state.selected << model
        set_state selected: state.selected
      end

      def handle_input_change(e)

        already_typed = `#{e}.target.value`

        state.options.data = []

        HTTP.get("/api#{state.autocomplete_url}", {payload: {typed: already_typed}}).then do |response|
          begin
          _options = state.parsing_model.parse(response.json)

          state.options.data += _options.data

          set_state options: state.options
          rescue Exception => e
            p e
          end
        end

      end

      def collect
        props.model.attributes[props.attr] = state.selected
      end

    end
  end
end
