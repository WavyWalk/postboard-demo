class ComposerFor::Notifications::SetRead < ComposerFor::Base

  def initialize(notification_id:, current_user:)
    @notification_id = notification_id
    @current_user = current_user
  end

  def before_compose
    find_and_set_notification!
    check_if_notification_user_doesnt_match_current_user!
    update_notification_as_read
  end

  def find_and_set_notification!
    notification = Notification.where(id: @notification_id).first    
    if notification
      @notification = notification
    else
      fail_immediately(:notification_not_found)
    end
  end

  def check_if_notification_user_doesnt_match_current_user!
    user_id_in_notification = @notification.user_id
    if user_id_in_notification != @current_user.id
      fail_immediately(:notification_user_id_doesnt_match_current_user_id)
    end 
  end

  def update_notification_as_read
    @notification.read = Time.now
  end

  def compose
    @notification.save!
  end

  def resolve_success
    publish(:ok, @notification)
  end

  def resolve_fail(e)
    
    case e
    when :notification_not_found
      publish(:notification_not_found)
    when :notification_user_id_doesnt_match_current_user_id
      publish(:notification_user_id_doesnt_match_current_user_id)
    else
      raise e
    end

  end

end
