module Components
  module Staff
    module UserSubmitted
      module PostTexts
        class Edit < RW

          expose

          include Plugins::Formable

          def validate_props

          end

          def get_initial_state
            {
              form_model: props.post_text
            }
          end

          def render
            t(:div, {},
              input(Components::Forms::Input, state.form_model, :content, {})
            )
          end

          def reap_inputs
            current_content = state.form_model.content
            collect_inputs
            if current_content != state.form_model.content
              (state.form_model.attributes[:changed] ||= {})[:content] = {from: current_content, to: state.form_model.content}
            end
          end

        end
      end
    end
  end
end
