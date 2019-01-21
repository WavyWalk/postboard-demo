module Components
  module PostTests
    class Edit < RW
      expose

      include Plugins::Formable

      attr_accessor :comps_to_call_collect_on

      def get_initial_state
        #unused but needed for some children
        @comps_to_call_collect_on = []
        #post_test = n_prop(:post_test)
        {
          post_test: false,
          image_roster: [],
          post_is_changed: false
        }
      end

      def component_did_mount
        id = n_prop(:post_test).id
        ::PostTest.show(wilds: {id: id}).then do |post_test|
          begin
          n_prop(:post_test).attributes = post_test.attributes
          set_state({post_test: n_prop(:post_test)})
          rescue Exception => e
            p e
          end
        end
      end

      def render
        if n_state(:post_test)
          t(:div, {},
            modal,

            if x = n_state(:post_test).errors[:general]
              x.map do |er|
                t(:p, {}, er)
              end
            end,
            if n_state(:post_is_changed)
              t(:button, {onClick: ->{update_post_test_attributes}}, 'update')
            end,
            input(Forms::Input, n_state(:post_test), :title,
              {
                show_name: 'enter name', required_field: true,
                on_change: event(->{set_post_is_changed})
              }
            ),

            t(:div, {className: 'PostTests-thumbnail'},
              if x = n_state(:post_test).errors[:tumbnail]
                x.map do |er|
                  t(:p, {}, er)
                end
              end,
              t(Components::PostImages::Show, {post_image: n_state(:post_test).thumbnail}),
              t(:button, 
                {
                  onClick: ->{start_replacing_thumbnail}
                }, 
                "replace thumbnail"
              )
            ),

            n_state(:post_test).test_questions.map do |question|
              t(Components::PostTests::Questions::Edit,
                {
                  key: "#{question}",
                  question: question, owner: self,
                  owner: self, on_delete: ->{delete_question(question)},
                  image_roster: n_state(:image_roster)
                }
              )
            end,
            t(:button, {onClick: ->{init_question_addition}}, "add_question"),

            n_state(:post_test).post_test_gradations.map do |gradation|
              t(Components::PostTests::Gradations::Edit,
                {
                  key: "#{gradation}",
                  save_in_place: true, owner: self,
                  image_roster: n_state(:image_roster),
                  on_delete: event(->{delete_gradation(gradation)}),
                  gradation: gradation
                }
              )
            end,
            t(:button, {onClick: ->{init_gradation_addition}}, 'add gradation'),
            t(:button, {onClick: ->{emit(:on_cancel)}}, "end editing")
          )
        else
          t(:div, {})
        end
      end

      #this is called from child and passed in proc to it's prop :on_delete
      def delete_question(question)
        n_state(:post_test).test_questions.data.delete(question)
        set_state post_test: n_state(:post_test)
      end

      #opens model, when child saves to server succefully calls on_done: #insert_question as event
      def init_question_addition
        modal_open(
          nil,
          t(Components::PostTests::Questions::New,
            {
              owner: self,
              question: TestQuestion.new, save_in_place: true,
              on_done: event(->(question){ insert_question(question) }),
              image_roster: n_state(:image_roster)
            }
          )
        )
      end
      #this is called from child and passed in proc to it's prop :on_done
      def insert_question(question)
        modal_close
        n_state(:post_test).test_questions << question
        set_state post_test: n_state(:post_test)
      end


      def init_gradation_addition
        modal_open(
          nil,
          t(Components::PostTests::Gradations::NewForEdit, #TODO: plain New was written erronously, and handles gradation at bulk when it should handle individualy.
            {
              owner: self,
              save_in_place: true,
              gradation: PostTestGradation.new,
              on_done: event(->(gradation){insert_gradation(gradation)}),
              image_roster: n_state(:image_roster)
            }
          )
        )
      end

      def insert_gradation(gradation)
        modal_close
        n_state(:post_test).post_test_gradations.data << gradation
        set_state post_test: n_state(:post_test)
      end

      def delete_gradation(gradation)
        n_state(:post_test).post_test_gradations.data.delete(gradation)
        set_state post_test: n_state(:post_test)
      end

      def start_replacing_thumbnail
        modal_open(
          t(Components::PostImages::UploadAndPreview,
            {
              on_image_selected: event(->(image){change_thumbnail(image)}),
              post_images: n_state(:image_roster)
            }
          )
        )
      end
      #called from child
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

      #if attributes on post_test are changed (not it's associated models) this is called
      #, serves to whether show update post_test button.
      def set_post_is_changed
        unless n_state(:post_is_changed)
          set_state post_is_changed: true
        end
      end

      #updates attributes on post_test like title *(currently only title)
      def update_post_test_attributes
        #check, should not update children
        collect_inputs
        n_state(:post_test).update.then do |post_test|
          if post_test.has_errors?
            set_state post_test: n_state(:post_test)
          else
            set_state({post_test: n_state(:post_test), post_is_changed: false})
          end
        end
      end


    end
  end
end
