module Components
  module PostTests
    module Gradations
      class Show < RW
        expose

        def get_initial_state
          {
            gradation: n_prop(:gradation)
          }
        end

        def render
          gradation = n_state(:gradation)
          t(:div, {className: 'PostTestsGradations-Show'},
            t(:p, {}, "your result:"),
            t(:h1, {className: 'msg'}, gradation.message),
            if n_state(:gradation).content
              t(:div, {className: 'm_content'},
                t(Components::PostImages::Show, {post_image: gradation.content})
              )
            end
          )
        end

      end
    end
  end
end