class NotificationsController < ApplicationController

  def index
    if current_user
      notifications = Notification.qo.unread_for_user(id: current_user.id).get_result || []
      render json: notifications
    else
      render json: []
    end
  end

  def set_read

    id = params[:id]

    cmpsr = ComposerFor::Notifications::SetRead.new(notification_id: id, current_user: current_user)

    cmpsr.when(:ok) do |notification|
      render json: notification.as_json
    end

    cmpsr.when(:notification_not_found) do
      render json: {errors: [{general: ['not_found']}]}
    end

    cmpsr.when(:notification_user_id_doesnt_match_current_user_id) do
      render json: {errors: [{general: ['incorrect_user']}]}
    end

    cmpsr.run

  end

end
