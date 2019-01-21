module Components
  module Posts
    class Main < RW
      expose

      def render
        t(:div, {className: "Posts-Main"}, 
          children
        )
      end

    end
  end
end