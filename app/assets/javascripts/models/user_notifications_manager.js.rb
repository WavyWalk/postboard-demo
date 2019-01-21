class UserNotificationsManager

  include Plugins::PubSubBus

  class << self
    attr_accessor :instance
  end

  def self.instance
    @instance || self.new
  end

  def initialize
    p 'initializing notif poller'
    self.class.instance = self
    @notifications = ModelCollection.new
    @interval = Services::Interval.new(5000) do
      fetch_notifications
      @interval.stop
      @interval = Services::Interval.new(30000) do
        fetch_notifications
      end
      @interval.start
    end
    @interval.start
  end

  def notifications
    @notifications
  end

  def stop_polling
    @interval.stop
  end

  def fetch_notifications
    Notification.index.then do |_notifications|
      if !_notifications.empty?
        current_ids = @notifications.map(&:id)
        _notifications.each do |_notification|
          if !current_ids.include?(_notification.id)
            @notifications.data << _notification
          end
        end
        publish(:when_notifications_updated)
      end
    end
  end

  def remove_notification_and_set_it_read(notification)
    notifications.remove(notification)
    notification.set_read
    publish(:when_notifications_updated)
  end

end
