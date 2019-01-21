module Components
  module Staff
    module UserSubmitted
      module Posts
        class EditTitle < RW
          expose

          include Plugins::Formable

          def get_initial_state
            {
              form_model: props.post
            }
          end

          def render
            t(:div, {},
              input(Components::Forms::Input, state.form_model, :title, {})
            )
          end

          def reap_inputs
            current_title = state.form_model.title
            collect_inputs(form_model: :form_model)
            if current_title != state.form_model.title
              (state.form_model.attributes[:changed] ||= {})[:title] = {from: current_title, to: state.form_model.title}
            end
          end

        end
      end
    end
  end
end
