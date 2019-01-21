class ModelQuerier::Notification

  def initialize(qo = ::Notification)
    @qo = qo
  end

  def get_result
    @qo
  end

  def unread_for_user(id:)
    @qo = @qo.where(user_id: id, read: nil)
    self
  end

end