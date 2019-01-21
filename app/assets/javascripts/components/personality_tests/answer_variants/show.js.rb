module Components
  module PersonalityTests
    module AnswerVariants
      class Show < RW
        expose

        def validate_props
          # variant: TestAnswerVariant,
          # on_selected: ->(variant){on_selected(variant)},
          # answered: Boolean
        end

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
          selected_css = n_state(:selected) ? "correctSelected" : ""
          t(:div, {className: "PostTestsAnswerVariants-Show #{active} #{selected_css}", onClick: ->{select unless n_prop(:answered)}},
            if variant.text
              t(:h4, {className: "text"}, variant.text)
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

        def select
          set_state(selected: true)
          emit(:on_selected, n_state(:variant))
        end

      end
    end
  end
end