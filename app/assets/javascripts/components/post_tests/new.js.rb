module Components
  module PostTests
    class New < RW
      expose

      def validate_props
        #on_done : ProcEvent required
        #on_cancel : ProcEvent required
      end

      include Plugins::Formable

      attr_accessor :comps_to_call_collect_on

      def get_initial_state
        @comps_to_call_collect_on = []
        post_test =  n_prop(:post_test) || ::PostTest.new
        post_test.post_test_gradations = ModelCollection.new
        {
          post_test: post_test,
          image_roster: []
        }
      end

      def render
        t(:div, {className: 'PostTests-New'},
          modal,
          if x = n_state(:post_test).errors[:general]
            t(:div, {className: 'errors-group'},
              t(:p, {}, 'your input has these errors'),
              x.map do |er|
                t(:p, {}, er)
              end
            )
          end,
          t(:div, {className: 'questionRelated-group'},
            t(:div, {className: 'title'},
              input(Forms::Input, n_state(:post_test), :title, {show_name: 'enter name', required_field: true})
            ),
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
          t(:div, {className: 'TestQuestions-container'},
            n_state(:post_test).test_questions.map do |question|
              t(Components::PostTests::Questions::New, {question: question, owner: self, on_delete: ->{delete_question(question)}, image_roster: n_state(:image_roster)})
            end,
            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{add_question}, className: 'btn btn-sm'}, "add question")
            )
          ),
          t(:div, {className: 'TestGradations-container'},
            t(Components::PostTests::Gradations::New, {owner: self, gradations: n_state(:post_test).post_test_gradations, image_roster: n_state(:image_roster)})
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

      def add_question(question)
        n_state(:post_test).test_questions << TestQuestion.new
        set_state post_test: n_state(:post_test)
      end

      def handle_inputs
        @comps_to_call_collect_on.each(&:handle_inputs)
        collect_inputs(form_model: :post_test)
        n_state(:post_test).create.then do |post_test|
          begin
          if post_test.has_errors?
            set_state post_test: post_test
          else
            if n_prop(:on_collect)
              n_prop(:on_collect).call(n_state(:post_test), self)
              return
            end
            emit(:on_done, post_test)
          end
          rescue Exception => e
            p e
          end
        end
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

    end
  end
end
