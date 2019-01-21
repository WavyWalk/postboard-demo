module Components
  module PostTests
    module AnswerVariants
      class Show < RW
        expose

        def get_initial_state
          variant = n_prop(:variant)
          {
            variant: variant,
            selected: false
          }
        end


        def render
          variant = n_state(:variant)
          active = n_prop(:answered) ? "" : "active"
          t(:div, {className: "PostTestsAnswerVariants-Show #{active} #{get_correct_or_incorrect_css_class}", onClick: ->{select unless n_prop(:answered)}},

            if n_state(:selected) && variant.on_select_message
              t(:p, {className: 'onSelectMsg'},
                variant.on_select_message
              )
            end,
            if n_state(:variant).is_selected && n_state(:variant).on_select_message
              t(:p, {className: 'on_select_message'}, n_state(:variant).on_select_message)
            else
              if variant.text
                t(:h4, {className: "text"}, variant.text)
              end
            end,
            if variant.content && variant.content_type == 'PostImage'
              t(Components::PostImages::Show, {post_image: variant.content, css_class: 'media_thumb'})            
            end,
            unless n_prop(:answered)
              t(:div, {className: 'button-wrap'},
                t(:button, {className: 'btn btn-sm btn-primary'}, "select")
              )
            end
          )
        end

        def get_correct_or_incorrect_css_class
          if n_state(:variant).is_selected
            if n_state(:variant).correct
              "correctSelected"
            else
              "incorrectSelected"
            end
          else
            ""
          end
        end


        def select
          variant = n_state(:variant)
          variant.is_selected = true
          set_state(variant: variant)
          emit(:on_selected, variant)
        end

      end
    end
  end
end