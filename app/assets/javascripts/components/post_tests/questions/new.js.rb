module Components
  module PostTests
    module Questions
      class New < RW
        expose

        include Plugins::Formable
        attr_accessor :comps_to_call_collect_on

        def validate_props
          #owner required
          #on_done optional if no save_in_place
          #save_in_place optional # if passed this will render button to save directly, not by parent
        end

        def get_initial_state
          #will send to variants/new so this can collect later from them directly
          @comps_to_call_collect_on = []
          question = n_prop(:question)
          {
            question: question
          }
        end

        def render
          t(:div, {className: 'TestQuestions-New'},

            modal,

            t(:div, {className: 'g-errors-group'},
              if n_prop(:question).errors
                n_prop(:question).errors.map do |er|
                  t(:p, {}, er)
                end
              end
            ),

            input(Forms::Input, n_state(:question), :text, {show_name: "question", required_field: true}),

            if n_state(:question).content && n_state(:question).question_type == "PostImage"
              t(:div, {className: 'thumbnail'},
                t(Components::PostImages::Show, {post_image: n_state(:question).content}),
                t(:div, {className: 'g-btn-group'},
                  t(:button, {onClick: ->{delete_image}, className: 'btn btn-sm'}, "remove this")
                )
              )
            else
              t(:div, {className: 'g-btn-group'},
                t(:button, {onClick: ->{init_image_insertion}, className: 'btn btn-sm'}, "add image")
              )
            end,

            t(:div, {className: 'variants-container'},
              n_state(:question).test_answer_variants.data.map do |variant|
                t(Components::PostTests::AnswerVariants::New,
                  {
                    owner: self, variant: variant,
                    on_delete: ->{delete(variant)}, image_roster: n_prop(:image_roster)
                  }
                )
              end,
              t(:div, {className: 'g-btn-group'},
                t(:button, {onClick: ->{add_variant}, className: 'btn btn-sm'}, "add_variant"),
              )
            ),

            t(:div, {className: 'on_answered_m_content'},
              t(:p, {}, "you can add here a text and an image that will be shown after the question is answered"),
              input(Forms::Input, n_state(:question), :on_answered_msg, {show_name: 'text', required_field: false}),
              t(:div, {className: 'btn-container'},
                if n_state(:question).on_answered_m_content
                  t(:div, {className: 'on_answered_m_content_preview'},
                    t(Components::PostImages::Show, {post_image: n_state(:question).on_answered_m_content}),
                    t(:button, {onClick: ->{delete_on_answered_content}}, 'remove this')
                  )
                else
                  t(:button, {onClick: ->{init_image_insertion_for_on_answered}, className: 'btn btn-xs'}, "insert image")
                end
              )
            ),

            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{emit(:on_delete)}, className: 'btn btn-sm'}, "delete")
            ),
            #if is child for post_test/edit
            if n_prop(:save_in_place)
              t(:button, {onClick: ->{submit_when_save_in_place}}, 'save')
            end
          )
        end

        def add_variant
          n_state(:question).test_answer_variants.data << TestAnswerVariant.new
          set_state question: n_state(:question)
        end

        def delete(variant)
          n_state(:question).test_answer_variants.data.delete(variant)
          set_state question: n_state(:question)
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:save_in_place)
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:save_in_place)
        end

        def handle_inputs
          @comps_to_call_collect_on.each(&:handle_inputs)
          collect_inputs(form_model: :question)
        end

        def init_image_insertion
          modal_open(
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image(image)}), post_images: n_prop(:image_roster) } )
          )

        end

        def insert_image(image)
          modal_close
          n_state(:question).content = image
          n_state(:question).question_type = "PostImage"
          n_state(:question).content_type = 'PostImage'
          set_state question: n_state(:question)
        end

        def delete_image
          n_state(:question).content = nil
          n_state(:question).content_type = nil
          n_state(:question).question_type = nil
          set_state question: n_state(:question)
        end

        def init_image_insertion_for_on_answered
          modal_open(
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image_to_on_answered(image)}), post_images: n_prop(:image_roster) } )
          )          
        end

        def insert_image_to_on_answered(image)
          modal_close
          n_state(:question).on_answered_m_content = image
          n_state(:question).on_answered_m_content_type = "PostImage"
          set_state question: n_state(:question)
        end

        def delete_on_answered_content
          n_state(:question).on_answered_m_content = nil
          n_state(:question).on_answered_m_content_type = nil
          set_state question: n_state(:question)
        end

        #only if child of post_test/edit
        def submit_when_save_in_place
          handle_inputs
          n_state(:question).create(wilds: {post_test_id: n_prop(:owner).n_state(:post_test).id}).then do |question|
            if question.has_errors?
              set_state question: question
            else
              emit(:on_done, question)
            end
          end
        end

      end
    end
  end
end
