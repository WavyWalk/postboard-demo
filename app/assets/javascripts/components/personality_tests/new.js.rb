module Components
  module PersonalityTests
    class New < RW
      expose

      include Plugins::Formable

      def get_initial_state
        @comps_to_call_collect_on = []
        {
          post_test: PostTest.new(is_personality: true),
          image_roster: []
        }
      end

      def comps_to_call_collect_on
        @comps_to_call_collect_on
      end

      def render
        t(:div, {className: 'PostTests-New PersonalityTests'},
          modal, 
          if errors = n_state(:post_test).errors[:general]
            t(:div, {className: "invalid"},
              errors.map do |er|
                t(:p, {}, er)
              end
            )
          end,
          t(:div, {className: 'questionRelated-group'},
            t(:div, {className: 'title'},
              input(Forms::Input, n_state(:post_test), :title, 
                {
                  show_name: 'enter name', 
                  required_field: true,
                  collect_on_change: true
                }
              )
            ),
            if thumb_errors = n_state(:post_test).errors[:thumbnail]
              t(:p, {className: 'invalid'}, thumb_errors)
            end,
            if n_state(:post_test).thumbnail
              t(:div, {className: 'thumbnail'},
                t(Components::PostImages::Show, {post_image: n_state(:post_test).thumbnail}),
                t(:div, {className: 'g-btn-group'},
                  t(:button, {className: 'btn btn-sm', onClick: ->{delete_thumbnail}}, "delete")
                )
              )
            else
              t(:div, {className: 'g-btn-group'},
                t(:button, {className: 'btn btn-sm', onClick: ->{init_thumbnail_insertion}}, "add image thumbnail")
              )
            end
          ),
          t(:div, {className: 'personalities-group'},
            n_state(:post_test).p_t_personalities.map do |p_t_personality|
              t(Components::PostTests::PersonalityTests::Personalities::New, 
                {
                  p_t_personality: p_t_personality,
                  owner: self,
                  on_delete: ->{delete_personality(p_t_personality)},
                  image_roster: n_state(:image_roster)
                }
              )
            end,
            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{add_personality}, className: 'btn btn-sm'},
                "add personality"
              )
            )
          ),
          t(:div, {className: 'TestQuestions-container'},
            n_state(:post_test).test_questions.map do |question|
              t(Components::PostTests::PersonalityTests::Questions::New, 
                {
                  question: question, 
                  owner: self, 
                  on_delete: ->{delete_question(question)}, 
                  image_roster: n_state(:image_roster)
                }
              )
            end,
            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{add_question}, className: 'btn btn-sm'}, "add question")
            )
          ),
          t(:div, {className: 'g-btn-group'},
            t(:button, {onClick: ->{handle_inputs}, className: 'btn btn-sm'}, "submit"),
            t(:button, {onClick: ->{emit(:on_cancel)}, className: 'btn btn-sm'}, "cancel")
          )
        )      
      end

      def delete_question(question)
        n_state(:post_test).test_questions.data.delete(question)
        set_state post_test: n_state(:post_test)
      end

      def add_question
        n_state(:post_test).test_questions << TestQuestion.new
        set_state post_test: n_state(:post_test)
      end

      def add_personality
        personality = P_T_Personality.new
        n_state(:post_test).p_t_personalities << personality
        add_personality_to_question_variants(personality)
        set_state post_test: n_state(:post_test)
      end

      def delete_personality(p_t_personality)
        n_state(:post_test).p_t_personalities.data.delete(p_t_personality)
        delete_personality_from_question_variants(p_t_personality)
        set_state post_test: n_state(:post_test)
      end


      def init_thumbnail_insertion
        modal_open(
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_thumbnail(image)}), 
              post_images: n_state(:image_roster) 
            } 
          )
        )
      end

      def insert_thumbnail(image)
        modal_close
        n_state(:post_test).thumbnail = image
        set_state post_test: n_state(:post_test)
      end

      def delete_thumbnail
        n_state(:post_test).thumbnail = nil
        set_state post_test: n_state(:post_test)
      end

      def handle_inputs
        @comps_to_call_collect_on.each(&:handle_inputs)
        collect_inputs(form_model: :post_test)
        n_state(:post_test).create_personality.then do |post_test|
          begin
          if post_test.has_errors?
            post_test.test_questions.each do |test_question|
              test_question.test_answer_variants.each do |variant|
                populate_variant_personality_scales_with_personality(variant)
              end
            end
            set_state post_test: post_test
          else
            emit(:on_done, n_state(:post_test))
          end
          rescue Exception => e
            p e
            raise e
          end
        end.fail do |er|
          raise er
        end
      end

      def populate_variant_personality_scales_with_personality(variant)
        n_state(:post_test).p_t_personalities.each do |personality|
          variant.personality_scales.each do |personality_scale|
            personality_scale.p_t_personality = personality
          end
        end
      end

      def populate_variant_with_personality_scales(variant)
        n_state(:post_test).p_t_personalities.each do |personality|
          personality_scale = PersonalityScale.new
          personality_scale.p_t_personality = personality
          variant.personality_scales << personality_scale
        end
      end

      def delete_personality_from_question_variants(personality)
        post_test = n_state(:post_test)
        index = post_test.p_t_personalities.data.find_index(personality)

        post_test.test_questions.each do |test_question|
          test_question.test_answer_variants.each do |test_answer_variant|
            test_answer_variant.personality_scales.data.delete_at(index)
          end
        end
      end

      def add_personality_to_question_variants(personality)
        n_state(:post_test).test_questions.each do |test_question|
          test_question.test_answer_variants.each do |test_answer_variant|
            personality_scale = PersonalityScale.new
            personality_scale.p_t_personality = personality
            test_answer_variant.personality_scales << personality_scale
          end
        end
      end

    end
  end
end