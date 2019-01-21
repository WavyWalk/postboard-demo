module Components
  module UserNotifications
    class PostIndexIndex < RW
      expose

      def get_initial_state
        {
          notifications_manager: UserNotificationsManager.instance
        }     
      end

      def component_did_mount
        state.notifications_manager.subscribe(:when_notifications_updated, self) 
      end


      def render
        t(:div, {className: 'userNotifications-index on-index'}, 
          if !state.notifications_manager.notifications.empty?
            t(:p, {className: 'messageInformer'}, "you've got a new message")
          end,
          state.notifications_manager.notifications.map do |user_notification|
            t(:div, {className: "Notification-Show"},
              t(:div, {className: 'text', dangerouslySetInnerHTML: {__html: user_notification.content}.to_n}),
              t(:button, {className: 'controll btn btn-primary btn-xs', onClick: ->{remove_notification(user_notification)}}, 'got it!')

            )
          end
        )
      end

      def component_will_unmount
        state.notifications_manager.unsubscribe(:when_notifications_updated, self)
      end

      def when_notifications_updated
        set_state notifications_manager: state.notifications_manager
        if state.notifications_manager.notifications.empty? && n_prop('owner')
          props.owner.notifications_emptied(n_prop(:arbitrary_id))
        end
      end

      def remove_notification(user_notification)
        state.notifications_manager.remove_notification_and_set_it_read(user_notification)
      end

    end
  end
end