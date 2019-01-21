module Components
  module PersonalityTests
    class Edit < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          post_test: false,
          post_title_is_changed: false
        }
      end

      def component_did_mount
        id = n_prop(:post_test_id)
        ::PostTest.personality_test_edit(wilds: {id: id}).then do |post_test|
          begin
          add_p_t_personalities_to_personality_scales(post_test)
          set_state(post_test: post_test)
          rescue Exception => e
            p e
          end
        end
      end

      def add_p_t_personalities_to_personality_scales(post_test)
        personalities_mapped_by_id = {}
        post_test.p_t_personalities.each do |personality_scale|
          personalities_mapped_by_id[personality_scale.id] = personality_scale
        end
        post_test.test_questions.each do |test_question|
          test_question.test_answer_variants.each do |variant|
            variant.personality_scales.each do |personality_scale|
              personality_to_assign = personalities_mapped_by_id[personality_scale.p_t_personality_id]
              personality_scale.p_t_personality = personality_to_assign
            end
          end
        end
        post_test
      end

      def render

        t(:div, {className: 'PersonalityTests-Edit'},
          modal,
          if n_state(:post_test)
            t(:div, {},
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
                      collect_on_change: true,
                      on_change: ->{set_state(post_title_is_changed: true)}
                    }
                  ),
                  if n_state(:post_title_is_changed)
                    t(:button, {onClick: ->{update_title}}, 'update title')
                  end
                ),
                if n_state(:post_test).thumbnail
                  t(:div, {className: 'thumbnail'},
                    t(Components::PostImages::Show,
                      {
                        post_image: n_state(:post_test).thumbnail
                      }
                    ),
                    t(:div, {className: 'g-btn-group'},
                      t(:button, {className: 'btn btn-sm', onClick: ->{start_replacing_thumbnail}}, "replace thumbnail")
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
                  if p_t_personality.id
                    t(Components::PostTests::PersonalityTests::Personalities::Edit,
                      {
                        p_t_personality: p_t_personality,
                        owner: self,
                        on_delete: ->{delete_personality(p_t_personality)},
                        image_roster: []
                      }
                    )
                  else
                    t(Components::PostTests::PersonalityTests::Personalities::New,
                      {
                        p_t_personality: p_t_personality,
                        owner: self,
                        on_delete: ->{delete_personality(p_t_personality)},
                        image_roster: [],
                        edit_mode: true,
                        on_p_t_personality_created: ->{on_p_t_personality_created(p_t_personality)}
                      }
                    )
                  end
                end,
                t(:div, {className: 'g-btn-group'},
                  t(:button, {onClick: ->{add_personality}, className: 'btn btn-sm'},
                    "add personality"
                  )
                )
              ),
              t(:div, {className: 'TestQuestions-container'},
                n_state(:post_test).test_questions.map do |question|
                  if question.id
                    t(Components::PostTests::PersonalityTests::Questions::Edit,
                      {
                        question: question,
                        owner: self,
                        on_delete: ->{delete_question(question)},
                        image_roster: []
                      }
                    )
                  else
                    t(Components::PostTests::PersonalityTests::Questions::New,
                      {
                        question: question,
                        owner: self,
                        on_delete: ->{delete_question(question)},
                        image_roster: [],
                        edit_mode: true
                      }
                    )
                  end
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
        )

      end

      def add_question
        test_question = TestQuestion.new
        test_question.post_test_id = n_state(:post_test).id
        n_state(:post_test).test_questions << test_question
        force_update
      end

      def update_title
        collect_inputs
        n_state(:post_test).update.then do |post_test|
          if post_test.has_errors?
            set_state post_test: n_state(:post_test)
          else
            set_state({post_test: n_state(:post_test), post_title_is_changed: false})
          end
        end
      end

      def start_replacing_thumbnail
        modal_open(
          t(Components::PostImages::UploadAndPreview,
            {
              on_image_selected: event(->(image){change_thumbnail(image)}),
              post_images: []
            }
          )
        )
      end

      def change_thumbnail(image)
        modal_close
        image.update_thumbnail(wilds: {post_test_id: n_state(:post_test).id, id: image.id}).then do |pi|
          if pi.has_errors?
            pi.errors.each do |er|
              n_state(:post_test).add_error(:thumbnail, "thumbnail: #{er}")
            end
            set_state post_test: n_state(:post_test)
          else
            n_state(:post_test).thumbnail = pi
            set_state post_test: n_state(:post_test)
          end
        end
      end

      def add_personality
        personality = P_T_Personality.new
        personality.post_test_id = n_state(:post_test).id
        n_state(:post_test).p_t_personalities << personality
        #add_personality_to_question_variants(personality)
        set_state post_test: n_state(:post_test)
      end

      def on_p_t_personality_created(personality)
        variant_id_to_personality_scale = {}
        personality.personality_scales.each do |personality_scale|
          personality_scale.p_t_personality = personality
          variant_id_to_personality_scale[personality_scale.test_answer_variant_id] = personality_scale
        end
        n_state(:post_test).test_questions.each do |test_question|
          test_question.test_answer_variants.each do |test_answer_variant|
            personality_scale_to_add = variant_id_to_personality_scale[test_answer_variant.id]
            test_answer_variant.personality_scales.data << personality_scale_to_add
          end
        end
        personality.personality_scales = ModelCollection.new
        force_update
      end

      def delete_personality(p_t_personality)
        n_state(:post_test).p_t_personalities.data.delete(p_t_personality)
        delete_personality_from_question_variants(p_t_personality)
        set_state post_test: n_state(:post_test)
      end

      def delete_personality_from_question_variants(personality)
        n_state(:post_test).test_questions.each do |test_question|
          
          test_question.test_answer_variants.each do |test_answer_variant|

            personality_scale_to_delete = false
            
            test_answer_variant.personality_scales.data.each do |personality_scale|
              if personality_scale.p_t_personality == personality
                personality_scale_to_delete = personality_scale
              end
            end
            
            test_answer_variant.personality_scales.data.delete(personality_scale_to_delete) if personality_scale_to_delete
          
          end
        
        end
      end

      def populate_variant_with_personality_scales(variant)
        n_state(:post_test).p_t_personalities.each do |personality|
          personality_scale = PersonalityScale.new
          personality_scale.p_t_personality_id = personality.id
          personality_scale.p_t_personality = personality
          variant.personality_scales << personality_scale
        end
      end

      def populate_personality_scales_with_personalities(variant)
        index = 0
        variant.personality_scales.each do |personality_scale|
          personality_scale.p_t_personality = n_state(:post_test).p_t_personalities.data[index]
          index += 1 
        end
      end

      def delete_question(question)
        n_state(:post_test).test_questions.data.delete(question)
        force_update
      end

    end
  end
end
