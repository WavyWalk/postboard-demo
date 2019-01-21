module Components
  module PostTests
    class Show < RW
      expose

      def validate_props
        #post_test : PostTest required
      end

      def get_initial_state
        post_test = n_prop(:post_test)
        
        questions = get_questions
        total_questions = questions.data.length
       
        questions_answered = 0
        
        answer_tracker = {}
        questions.each do |question|
          answer_tracker[question] = nil
        end
       
        {
          post_test: post_test,
          completed: false,
          questions_answered: questions_answered,
          total_questions: total_questions,
          questions_answered_correctly: 0,
          answer_tracker: answer_tracker
        }
      end


      def get_questions
        # if n_prop(:show_serialized_fields)
        #   return n_prop(:post_test).s_questions
        # else
          return n_prop(:post_test).test_questions
        #end
      end

      def get_thumbnail
        # if n_prop(:show_serialized_fields)
        #   return n_prop(:post_test).s_thumbnail
        # else
          return n_prop(:post_test).thumbnail
        #end
      end

      def get_gradations
        # if n_prop(:show_serialized_fields)
        #   return n_prop(:post_test).s_gradations
        # else
          return n_prop(:post_test).post_test_gradations
        #end
      end

      def render
        test = n_state(:post_test)
        questions = get_questions
        thumbnail = get_thumbnail

        t(:div, {className: 'PostTests-Show'},
          
          t(:h2, {className: 'title'}, test.title),

          # n_state(:answer_tracker).map do |k, v|
          #   if v == true
          #     t(:h1, {}, "T")
          #   elsif v == false
          #     t(:h1, {}, "F")
          #   else
          #     t(:h1, {}, "--")
          #   end
          # end,

          if thumbnail
            t(Components::PostImages::Show, {post_image: thumbnail, css_class: 'thumbnail'})
          end,
          t(:div, {className: 'questionsContainer'},
            questions.data.map do |question|              
              t(Components::PostTests::Questions::Show, 
                {
                  key: question.id,
                  question: question,
                  on_answered: ->(question){on_answered(question)},
                  test_completed: n_state(:completed)
                }
              )
            end
          ),

          if n_state(:completed)
            show_correct_gradation
          end

        )
      end

      def on_answered(question)
        total_questions = n_state(:total_questions)
        questions_answered = n_state(:questions_answered)
        answered_correct = question.answered_correct
        answer_tracker = n_state(:answer_tracker)
        
        questions_answered_correctly = n_state(:questions_answered_correctly)

        if answered_correct
          answer_tracker[question] = true
          questions_answered_correctly += 1
        else
          answer_tracker[question] = false
        end

        questions_answered += 1

        completed = false
        if (total_questions - questions_answered) == 0
          completed = true
        end

        set_state({
          questions_answered: questions_answered,
          answer_tracker: answer_tracker,
          completed: completed,
          questions_answered_correctly: questions_answered_correctly
        })
      end

      def show_correct_gradation
        correct_count = n_state(:questions_answered_correctly)
        gradation_to_show = nil   
        gradations = get_gradations
        gradations.data.each do |gradation|
          if correct_count >= gradation.from && correct_count <= gradation.to
            gradation_to_show = gradation
          end
        end
        if gradation_to_show
          t(Components::PostTests::Gradations::Show, {gradation: gradation_to_show})
        end        
      end

    end
  end
end