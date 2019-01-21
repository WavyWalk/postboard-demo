module Components
  module PostTests
    module Questions
      class Edit < RW
        expose

        include Plugins::Formable
        attr_accessor :comps_to_call_collect_on
        def validate_props
          # on_delete event required
        end

        def get_initial_state
          @comps_to_call_collect_on = []
          question = n_prop(:question)
          {
            question: question,
            question_changed: false,
            on_answered_msg_changed: false
          }
        end

        def render
          t(:div, {},
            modal,
            if n_state(:question).errors
              n_state(:question).errors.map do |er|
                t(:p, {}, er)
              end
            end,
            t(:button, {onClick: ->{destroy_question}}, "delete this question"),
            if n_state(:question_changed)
              t(:button, {onClick: ->{update_question}}, 'udpate')
            end,
            input(Forms::Input, n_state(:question), :text,
              {
                show_name: "question", required_field: true,
                on_change: ->{set_question_changed}
              }
            ),

            if n_state(:question).content && n_state(:question).content_type == "PostImage"
              t(:div, {className: 'PostTest-Question-Image-Show'},
                t(Components::PostImages::Show, {post_image: n_state(:question).content}),
                t(:button, {onClick: ->{delete_image}}, "remove this image"),
                t(:button, {onClick: ->{init_image_insertion_to_content}}, 'replace this image')
              )
            else
              t(:button, {onClick: ->{init_image_insertion_to_content}}, "add image")
            end,

            n_state(:question).test_answer_variants.data.map do |variant|
              t(Components::PostTests::AnswerVariants::Edit,
                {
                  key: "#{variant}",
                  owner: self, variant: variant,
                  on_delete: ->{delete_variant(variant)}, image_roster: n_prop(:image_roster)
                }
              )
            end,

            t(:div, {className: 'on_answered_m_content'},
              t(:p, {}, "you can add here a text and an image that will be shown after the question is answered"),

              if n_state(:on_answered_msg_changed)
                t(:button, {onClick: ->{update_question}}, 'udpate')
              end,
              input(Forms::Input, n_state(:question), :on_answered_msg, {show_name: 'text', required_field: false, on_change: ->{set_on_answered_msg_changed}}),

              t(:div, {className: 'btn-container'},
                if n_state(:question).on_answered_m_content
                  t(:div, {className: 'on_answered_m_content_preview'},
                    t(Components::PostImages::Show, {post_image: n_state(:question).on_answered_m_content}),
                    t(:button, {onClick: ->{delete_on_answered_content}}, 'remove this')
                  )
                else
                  t(:button, {onClick: ->{init_image_insertion_for_on_answered_m_content}, className: 'btn btn-xs'}, "insert image")
                end
              )
            ),

            t(:button, {onClick: ->{init_variant_addition}}, "add_variant")
          )
        end


        def init_variant_addition
          modal_open(
            nil,
            t(Components::PostTests::AnswerVariants::New,
              {
                save_in_place: true, on_done: event(->(variant){insert_variant(variant)}),
                owner: self, variant: TestAnswerVariant.new, image_roster: n_prop(:image_roster)
              }
            )
          )
        end

        def insert_variant(variant)
          modal_close
          n_state(:question).test_answer_variants.data << variant
          set_state question: n_state(:question)
        end

        def delete_variant(variant)
          n_state(:question).test_answer_variants.data.delete(variant)
          set_state question: n_state(:question)
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

        def init_image_insertion_for_on_answered_m_content
          modal_open(
            t(Components::PostImages::UploadAndPreview,
              {
                on_image_selected: event(->(image){insert_image_to_on_answered_m_content(image)}),
                post_images: n_prop(:image_roster)
              }
            )
          )
        end

        def insert_image_to_content(image)
          modal_close
          image.update_test_question_as_content(wilds: {test_question_id: n_state(:question).id, id: image.id}).then do |u_img|
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_state(:question).add_error(:content, er)
              end
            else
              n_state(:question).content = u_img
              n_state(:question).content_type = 'PostImage'
            end
            set_state(question: n_state(:question))
          end
        end

        def insert_image_to_on_answered_m_content(image)
          modal_close
          image.update_test_question_as_on_answered_content(wilds: {test_question_id: n_state(:question).id, id: image.id}).then do |u_img|
            begin
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_state(:question).add_error(:on_answered_m_content, er)
              end
            else
              n_state(:question).on_answered_m_content = u_img
              n_state(:question).on_answered_m_content_type = 'PostImage'
            end
            set_state(question: n_state(:question))
            rescue Exception => e
              p e
            end
          end
        end

        def destroy_question
          n_state(:question).destroy.then do |question|
            question.validate
            if question.has_errors?
              set_state question: question
            else
              emit(:on_delete)
            end
          end
        end


        def delete_image
          n_state(:question).content.remove_from_test_question(wilds: {test_question_id: n_state(:question).id}).then do |image|
            if image.has_errors?
              image.errors.each do |er|
                n_state(:question).add_error(:content, er)
              end
            else
              n_state(:question).content_id = nil
              n_state(:question).content = nil
              n_state(:question).content_type = nil
            end
            set_state question: n_state(:question)
          end
        end

        def delete_on_answered_content
          n_state(:question).on_answered_m_content.remove_from_test_question_as_on_answered_m_content(wilds: {test_question_id: n_state(:question).id}).then do |image|
            begin
            if image.has_errors?
              image.errors.each do |er|
                n_state(:question).add_error(:on_answered_m_content, er)
              end
            else
              n_state(:question).on_answered_m_content_id = nil
              n_state(:question).on_answered_m_content = nil
            end
            set_state question: n_state(:question)
            rescue Exception => e
              p e
            end
          end
        end


        def update_question
          collect_inputs
          n_state(:question).update(wilds: {post_test_id: n_prop(:owner).n_state(:post_test).id}).then do |question|
            if question.has_errors?
              #check, should not update children
              set_state({question: question})
            else
              set_state({question_changed: false, on_answered_msg_changed: false, question: question})
            end
          end
        end

        def set_question_changed
          unless n_state(:question_changed)
            set_state(question_changed: true)
          end
        end

        def set_on_answered_msg_changed
          unless n_state(:on_answered_msg_changed)
            set_state(on_answered_msg_changed: true)
          end
        end


      end
    end
  end
end
