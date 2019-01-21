class ModelQuerier::UserSubscription

  def initialize(qo = false)
    @qo = qo
  end

  def self.where_subscribing_user(user_id:)
    ::User.current_user_id_for_argless_includes = user_id

    to_user_ids = UserSubscription.where('user_subscriptions.user_id = ?', user_id).map(&:to_user_id)

    User.where(id: to_user_ids).includes([:usub_with_current_user, :user_denormalized_stat, :user_karma])
    
    # ::UserSubscription.where(user_id: user_id)
    #   .includes(to_user: [:user_denormalized_stat, :user_karma])
  end

end
