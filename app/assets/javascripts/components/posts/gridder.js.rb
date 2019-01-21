module Components
  module Posts
    class Gridder < RW
      expose

      def render
        t(:p, {}, "GRIDDER!")  
      end

    end
  end
end