module Components
  module PostTests
    module Questions
      class Show < RW
        expose

        def get_initial_state
          answered = false 
          {
            question: n_prop(:question),
            answered_correct: nil,
            answered: false
          }
        end

        def render
          question = n_state(:question)
          t(:div, {className: "PostTestsQuestions-Show"},

            if question.text
              t(:h4, {className: 'text'}, question.text)
            end,

            if question.content && question.content_type == 'PostImage'
              t(Components::PostImages::Show, {post_image: question.content, css_class: 'thumbnail'})
            end,
            t(:div, {className: 'variantsContainer'},
              question.test_answer_variants.data.map do |variant|
                t(Components::PostTests::AnswerVariants::Show, 
                  {
                    variant: variant,
                    on_selected: ->(variant){on_selected(variant)},
                    answered: n_state(:answered) 
                  }
                ) 
              end
            ),
            if n_state(:answered)
              p n_state(:question).on_answered_m_content
              t(:div, {className: 'on_answered'},
                if x = question.on_answered_msg
                  t(:p, {className: 'msg'}, x)
                end,
                if x = question.on_answered_m_content
                  render_m_content
                end
              )
            end
          )
          
        end

        def render_m_content
          p "should render #{n_state(:question).on_answered_m_content}"
          t(:div, {className: 'm_content'},
            case content = n_state(:question).on_answered_m_content
            when PostImage
              t(Components::PostImages::Show, {post_image: content, css_class: 'img'})
            end
          )
        end
 
        def on_selected(variant)
          answered_correct = variant.correct
          n_state(:question).answered_correct = answered_correct
          set_state({
            answered_correct: answered_correct,
            answered: true
          })
          emit(:on_answered, n_state(:question))
        end

        def answered_correct
          n_state(:answered_correct)
        end


      end
    end
  end
end