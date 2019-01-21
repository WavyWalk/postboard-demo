module Components
  module PersonalityTests
    module Questions
      class Edit < RW
        expose

        include Plugins::Formable

        attr_accessor :comps_to_call_collect_on

        def get_initial_state
          @edit_mode = n_prop(:edit_mode) ? true : false
          @comps_to_call_collect_on = []
          {
            text_changed: false
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

            input(Forms::Input, n_prop(:question), :text,
              {
                show_name: "question", required_field: true,
                on_change: ->{set_text_changed}
              }
            ),

            if n_state(:text_changed)
              t(:button, {onClick: ->{update_text}}, 'update title')
            end,

            if n_prop(:question).content
              t(:div, {className: 'thumbnail'},
                t(Components::PostImages::Show, {post_image: n_prop(:question).content}),
                t(:div, {className: 'g-btn-group'},
                  t(:button, {onClick: ->{delete_image}, className: 'btn btn-sm'}, "remove image"),
                  t(:buttin, {onClick: ->{init_image_insertion_to_content}}, 'replace image')
                )
              )
            else
              t(:div, {className: 'g-btn-group'},
                t(:button, {onClick: ->{init_image_insertion_to_content}, className: 'btn btn-sm'}, "add image")
              )
            end,

            t(:div, {className: 'variants-container'},
              n_prop(:question).test_answer_variants.data.map do |variant|
                if variant.id
                  t(Components::PersonalityTests::AnswerVariants::Edit,
                    {
                      owner: self, variant: variant,
                      on_delete: ->{delete(variant)}, image_roster: []
                    }
                  )
                else
                  t(Components::PersonalityTests::AnswerVariants::New,
                    {
                      owner: self, variant: variant,
                      on_delete: ->{delete(variant)}, image_roster: [],
                      save_in_place: true
                    }
                  )
                end
              end,
              t(:div, {className: 'g-btn-group'},
                t(:button, {onClick: ->{add_variant}, className: 'btn btn-sm'}, "add_variant"),
              )
            ),

            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{emit(:on_delete)}, className: 'btn btn-sm'}, "delete")
            ),
            #if is child for post_test/edit
            t(:button, {onClick: ->{delete_question}},
              "delete this question"
            ),
            if n_prop(:save_in_place)
              t(:button, {onClick: ->{submit_when_save_in_place}}, 'save')
            end
          )
        end

        def set_text_changed
          set_state(text_changed: true)
        end

        def update_text
          collect_inputs
          n_prop(:question).update.then do |question|
            set_state(text_changed: false)
          end
        end


        def add_variant
          variant = TestAnswerVariant.new
          variant.test_question_id = n_prop(:question).id
          populate_variant_with_personality_scales(variant)
          n_prop(:question).test_answer_variants.data << variant
          force_update
        end

        def delete(variant)
          p 'deleting'
          n_prop(:question).test_answer_variants.data.delete(variant)
          force_update
        end

        def populate_variant_with_personality_scales(variant)
          n_prop(:owner).populate_variant_with_personality_scales(variant)
        end

        def handle_inputs
          @comps_to_call_collect_on.each(&:handle_inputs)
          collect_inputs(model: n_prop(:variant))
        end

        def init_image_insertion_to_content
          modal_open(
            t(Components::PostImages::UploadAndPreview,
              {
                on_image_selected: event(->(image){insert_image_to_content(image)}),
                post_images: n_prop(:image_roster)
              }
            )
          )
        end

        def insert_image_to_content(image)
          modal_close
          image.update_test_question_as_content(wilds: {test_question_id: n_prop(:question).id, id: image.id}).then do |u_img|
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_prop(:question).add_error(:content, er)
              end
            else
              n_prop(:question).content = u_img
              n_prop(:question).content_type = 'PostImage'
              n_prop(:question).content_id = u_img.id
            end
            force_update
          end
        end

        def delete_image
          n_prop(:question).content.remove_from_test_question(wilds: {test_question_id: n_prop(:question).id}).then do |image|
            if image.has_errors?
              image.errors.each do |er|
                n_prop(:question).add_error(:content, er)
              end
            else
              n_prop(:question).content_id = nil
              n_prop(:question).content = nil
              n_prop(:question).content_type = nil
            end
            force_update
          end
        end

        def populate_variant_scales_with_personalities(variant)
          n_prop(:owner).populate_personality_scales_with_personalities(variant)
        end

        def delete_question
          n_prop(:question).personality_test_destroy(wilds: {personality_test_id: n_prop(:question).post_test_id}).then do |test_question|
            if test_question.has_errors?
              force_update
            else
              emit(:on_delete, n_prop(:test_question))
            end
          end
        end

      end
    end
  end
end
