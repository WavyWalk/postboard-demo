class Users::NotificationsController < ApplicationController

  def index
    last_date = params['last_date']

    date_to_fetch_from = last_date.blank? ? Time.now : last_date

    notifications = Notification.where("user_id = ? and created_at < ?", current_user.id, date_to_fetch_from).order('created_at desc').limit(10)
    
    render json: notifications.as_json
  end

end
