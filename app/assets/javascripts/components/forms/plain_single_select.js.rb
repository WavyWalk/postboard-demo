module Components
  module Forms
    class PlainSingleSelect < RW
      expose

      def get_initial_state
        prepare_initial_state
      end

      def prepare_initial_state
        options = props.select_options
        preselected_option = props.preselected_option || false
        if preselected_option
          options.delete(preselected_option)
        end
        {
          open: false, #dropdown
          options: options,
          selected: [preselected_option]

        }
      end

      def render
        t(:div, {className: "dropdown #{state.open ? "open" : ""}"},
          t(:p, {}, "#{(props.show_name || props.attr)}"),
          t(:div, {className: "input-group"},
            t(:div, {className: "input-group-btn"},
              t(:button, {role: "button", "aria-haspopup" => "true", "aria-expanded" => "#{state.open ? "true" : "false"}",
                          className: "btn btn-default", onClick: ->{toggle_dropdown}},
                t(:span, {className: "caret"})
              )
            ),
            t(:div, {className: "form-control"},
              if state.selected[0]
                t(:p, {onClick: ->{deselect} },
                  state.selected[0].show_value
                )
              end
            )
          ),
          t(:ul, {className: "dropdown-menu"},
            state.options.map do |option|
              t(:li, {style: {cursor: "pointer"}.to_n, onClick: ->{select(option)}}, " ",
                option.show_value
              )
            end
          )
        )
      end

      def toggle_dropdown
        set_state open: !state.open
      end


      def deselect
        to_deselect  = state.selected.delete_at(0)
        options = state.options
        options << to_deselect
        set_state options: options, selected: []
      end

      def select(option)

        options = state.options

        previously_selected = state.selected.delete_at(0)

        selected = options.delete(option)

        options << previously_selected if previously_selected

        set_state options: options, selected: [selected]

      end

      def collect
        props.model.attributes[props.attr] = state.selected[0].select_value
      end

    end
  end
end
