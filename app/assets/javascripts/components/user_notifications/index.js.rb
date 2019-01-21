module Components
  module UserNotifications
    class Index < RW
      expose

      include Plugins::InfiniteScrollable

      def get_initial_state
        @notification_index_query_runnig = false
        {
          notifications: []
        }
      end

      def component_did_mount
        fetch_notifications
      end

      def component_will_unmount
        destroy_infinite_scroll_beacon
      end

      def fetch_notifications(last_date = nil)
        return if @notification_index_query_runnig
        @notification_index_query_runnig = true
        Notification.index_for_user(wilds: {user_id: CurrentUser.instance.id}, extra_params: {last_date: last_date}).then do |notifications|
          begin
          _notifications = n_state(:notifications) 
          new_notifications = _notifications += notifications.data
          set_state notifications: new_notifications

          if notifications.data.length < 1
            destroy_infinite_scroll_beacon
            return nil
          end

          listen_to_infinite_scroll_beacon
          @notification_index_query_runnig = false
          rescue Exception => e
            p e
          end 
        end
      end

      def handle_infinite_croll_beacon_reach
        fetch_notifications(n_state(:notifications)[-1].try(:created_at))    
      end

      def render
        t(:div, {className: 'userNotifications-index'}, 
          n_state(:notifications).map do |user_notification|
            next if user_notification.read
            t(:div, {className: 'Notification-Show'},
              t(:div, {className: 'text', dangerouslySetInnerHTML: {__html: user_notification.content}.to_n},
                
              ),
              t(:button, {className: 'controll btn btn-primary btn-xs', onClick: ->{set_read(user_notification)}}, 'got it!')
            )
          end,
          t(:p, {ref: "last_beacon"},
            next_page_infinite_scroll_beacon(n_state(:notifications).length - 1)
          )
        )
      end

      def set_read(notification)
        notification.set_read().then do |notification|
          force_update
        end
      end

    end
  end
end