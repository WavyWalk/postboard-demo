require 'models/user'
class CurrentUser < Model

  register
  # EXAMPLE ROUTES
  # route "Get_current_user", post: "users/current_user"
  route "Logout", delete: "sessions/logout"
  # route "Login", post: "login"
  # route "Request_password_reset", post: "password_resets"
  # route "Update_new_password", put: "password_resets/:id"

  extend Plugins::PubSubBus

  @instance ||= User.new()
  @logged_in = false

  class << self
    attr_accessor :instance
    attr_accessor :logged_in
  end

  def self.logged_in=(val)
    @logged_in = val
    if val
      self.publish(:user_logged_in, @user_instance)
    else
      self.publish(:user_logged_out, @user_instance)
    end
  end

  def self.ping_current_user(args = {})
    instance.ping_current_user(args)
  end

  def self.set_user_and_login_status(user, login_value)
    @instance = user
    self.logged_in = login_value
    ping_current_user.then do |user|
      @instance = user
      self.publish(:user_logged_in, user)
    end
    if app_instance = Components::App::Router.get_app_instance
      app_instance.force_update
    end
  end

  def self.after_route_logout(r)
    if r.response.ok?

      self.set_user_and_login_status(User.new, false)

      r.promise.resolve(@user_instance)
    else
      r.promise.reject(status: "error")
    end
  end

  def self.update_karma(amount)
    return unless amount
    return if amount == 0
    #@instance.user_karma.count += amount
    self.publish(:karma_changed, amount)
  end

  def self.instance_has_role?(role_name)
    @instance.user_roles.map(&:name).include?(role_name)
  end

  def self.has_unread_notifications
    to_return = @instance.notifications.each do |notification|
      if notification.read != nil
        break true
      end
      false
    end
    to_return
  end

  def self.unread_notifications_count
    count = 0
    @instance.notifications.each do |notification|
      if notification.read == nil
        count += 1
      end
    end
    count == 0 ? nil : count
  end

end
