module Components
  module PersonalityTests
    module Questions
      class New < RW
        expose

        include Plugins::Formable

        attr_accessor :comps_to_call_collect_on

        def get_initial_state
          @comps_to_call_collect_on = []
          {

          }
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:edit_mode)
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:edit_mode)
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

            input(Forms::Input, n_prop(:question), :text, {show_name: "question", required_field: true}),

            if n_prop(:question).content && n_prop(:question).question_type == "PostImage"
              t(:div, {className: 'thumbnail'},
                t(Components::PostImages::Show, {post_image: n_prop(:question).content}),
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
              n_prop(:question).test_answer_variants.data.map do |variant|
                t(Components::PersonalityTests::AnswerVariants::New,
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

            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{emit(:on_delete)}, className: 'btn btn-sm'}, "delete")
            ),
            #if is child for post_test/edit
            if n_prop(:edit_mode)
              t(:button, {onClick: ->{create_when_in_edit_mode}}, 'save')
            end
          )
        end


        def add_variant
          variant = TestAnswerVariant.new
          populate_variant_with_personality_scales(variant)
          n_prop(:question).test_answer_variants.data << variant
          force_update
        end

        def delete(variant)
          n_prop(:question).test_answer_variants.data.delete(variant)
          force_update
        end

        def populate_variant_with_personality_scales(variant)
          n_prop(:owner).populate_variant_with_personality_scales(variant)
        end

        def handle_inputs
          @comps_to_call_collect_on.each(&:handle_inputs)
          collect_inputs(model: n_prop(:question))
        end

        def insert_image(image)
          modal_close
          n_prop(:question).content = image
          n_prop(:question).question_type = "PostImage"
          n_prop(:question).content_type = 'PostImage'
          force_update
        end

        def delete_image
          n_prop(:question).content = nil
          n_prop(:question).content_type = nil
          n_prop(:question).question_type = nil
          force_update
        end

        def init_image_insertion_for_on_answered
          modal_open(
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image_to_on_answered(image)}), post_images: n_prop(:image_roster) } )
          )          
        end

        def create_when_in_edit_mode
          @comps_to_call_collect_on.each(&:handle_inputs)
          collect_inputs(model: n_prop(:question))
          n_prop(:question).personality_test_create(wilds: {personality_test_id: n_prop(:question).post_test_id}).then do |test_question|
            begin
            test_question.test_answer_variants.each do |variant|
              n_prop(:owner).populate_personality_scales_with_personalities(variant)
            end
            n_prop(:owner).force_update
            rescue Exception => e
              p e
            end
          end
        end

      end
    end
  end
end