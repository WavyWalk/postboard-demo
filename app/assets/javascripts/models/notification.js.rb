class Notification < Model

  register

  attributes :id, :content, :user_id, :read, :created_at

  route :Index, get: "notifications"

  route :set_read, {get: "notifications/set_read/:id"}, {defaults: [:id]}

  route :Index_for_user, {get: "users/:user_id/notifications"}

  def self.after_route_index_for_user(r)
    self.after_route_index(r)
  end

  def after_route_set_read(r)
    after_route_update(r)
  end

end