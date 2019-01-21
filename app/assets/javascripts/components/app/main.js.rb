module Components
  module App
    class Main < RW
      expose

      def render
        t(:div, {className: 'container-fluid'},
          t(Components::Shared::LoadIconPool, {}),
          t(Components::Menues::Top, {}),
          children
        )
      end

    end
  end
end