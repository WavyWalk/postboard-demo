module Components
  module PostTests
    module AnswerVariants
      class New < RW

        expose

        include Plugins::Formable

        def get_initial_state
          variant = n_prop(:variant)
          {
            variant: variant
          }
        end

        def render
          t(:div, {className: 'AnswerVariants-New'},

            modal,

            t(:div, {className: 'answer-group'},
              input(Forms::Input, n_state(:variant), :text, {show_name: "answer", required: true}),

              t(:div, {className: 'g-btn-group'},
                if n_state(:variant).correct
                  t(:button, {onClick: ->{toggle_correct}, className: 'btn btn-sm btn-success'}, 'mark as incorrect answer')
                else
                  t(:button, {onClick: ->{toggle_correct}, className: 'btn btn-sm btn-danger'}, 'mark as correct answer')
                end
              )
            ),

            t(:div, {className: 'm_content'},
              if n_state(:variant).content && n_state(:variant).content_type == "PostImage"
                t(:div, {className: 'PostTest-Variant-Image'},
                  t(Components::PostImages::Show, {post_image: n_state(:variant).content}),
                  t(:div, {className: 'g-btn-group'},
                    t(:button, {onClick: ->{delete_image}, className: 'btn btn-sm'}, "remove this")
                  )
                )
              else
                t(:div, {className: 'g-btn-group'},
                  t(:button, {onClick: ->{init_image_insertion}, className: 'btn btn-sm'}, "add image")
                )
              end
            ),

            t(:div, {className: 'on_select_msg'},
              input(Forms::Input, n_state(:variant), :on_select_message, {show_name: "message to show when selected", required: false}),
            ),

            t(:div, {className: 'g-btn-group'},
              unless n_prop(:save_in_place)
                t(:button, {onClick: ->{emit(:on_delete)}, className: 'btn btn-sm'}, 'delete')
              end,
              #if is child for post_test/edit
              if n_prop(:save_in_place)
                t(:button, {onClick: ->{submit_when_save_in_place}, className: 'btn btn-sm'}, 'save')
              end
            )
          )
        end

        def toggle_correct
          n_state(:variant).correct = !n_state(:variant).correct
          set_state variant: n_state(:variant)
        end

        def init_image_insertion
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image(image)}), post_images: n_prop(:image_roster) } )
          )
        end

        def insert_image(image)
          modal_close
          n_state(:variant).content = image
          #n_state(:variant).question_type = "PostImage"
          n_state(:variant).content_type = 'PostImage'
          set_state variant: n_state(:variant)
        end

        def delete_image
          n_state(:variant).content = nil
          n_state(:variant).content_type = nil
          #n_state(:variant).question_type = nil
          set_state variant: n_state(:variant)
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:save_in_place)
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:save_in_place)
        end

        def handle_inputs
          collect_inputs(form_model: :variant)
        end

        def submit_when_save_in_place
          collect_inputs
          n_state(:variant).create(wilds: {test_question_id: n_prop(:owner).n_state(:question).id}).then do |variant|
            if variant.has_errors?
              set_state variant: variant
            else
              emit(:on_done, variant)
            end
          end
        end

      end
    end
  end
end
