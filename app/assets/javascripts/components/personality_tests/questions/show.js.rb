module Components
  module PersonalityTests
    module Questions
      class Show < RW
        expose 

        def validate_props
          #test_question: TestQuestion - required
          #test_completed: Boolean - required
          #on_answered: EventProc - required
          #key: String - required
        end

        def get_initial_state
          {
            question: n_prop(:question),
            answered: false
          }
        end

        def render
          question = n_state(:question)

          t(:div, {className: "PostTestsQuestions-Show"},
            if question.text
              t(:h4, {className: 'text'}, question.text)
            end,

            if question.content
              t(Components::PostImages::Show, {post_image: question.content, css_class: 'thumbnail'})
            end,
            t(:div, {className: 'variantsContainer'},
              question.test_answer_variants.data.map do |variant|
                t(Components::PersonalityTests::AnswerVariants::Show, 
                  {
                    variant: variant,
                    on_selected: ->(variant){on_selected(variant)},
                    answered: n_state(:answered) 
                  }
                ) 
              end
            )
          )
        end

        def on_selected(variant)
          set_state(answered: true)
          emit(:on_answered, n_state(:question), variant)
        end

      end
    end
  end
end