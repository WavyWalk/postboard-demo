module Components
  module App
    class Sidebar < RW
      expose

      def render
        t(:div, {},
          t(Components::UserNotifications::Index, {})
        )
      end

    end
  end
end