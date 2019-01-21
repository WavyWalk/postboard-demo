module Components
  module Staff
    module Posts
      class Main < RW
        expose

        def render
          t(:div, {},
            children
          )
        end

      end
    end
  end
end
