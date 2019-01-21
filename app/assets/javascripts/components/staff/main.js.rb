module Components
  module Staff
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
