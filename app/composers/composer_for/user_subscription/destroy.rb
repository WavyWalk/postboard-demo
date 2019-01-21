class ComposerFor::UserSubscription::Destroy < ComposerFor::Base

  def initialize(params:, current_user:)
    @params = params
    @current_user = current_user
  end

  def before_compose
    set_user_subscription_id
    find_and_set_user_subscription!
    check_if_current_user_owns_subscription!
  end

  def set_user_subscription_id
    @user_subscription_id = @params[:id]
  end

  def find_and_set_user_subscription!
    @user_subscription = ::UserSubscription.find(@user_subscription_id)
  end

  def check_if_current_user_owns_subscription!
    if @user_subscription.user.id != @current_user.id
      fail_immediately(:current_user_is_not_owner_of_subcsription)
    end
  end



  def compose
    @user_subscription.destroy!
    update_denormalized_user_stats
    subtract_karmas_of_both_users
  end


  def update_denormalized_user_stats
    #subscribing_user
    subscribing_user_denormalized_stat = ::UserDenormalizedStat.where(user_id: @user_subscription.user_id).first
    subscribing_user_denormalized_stat.updater_service.increment_subscriptions_count(-1)
    subscribing_user_denormalized_stat.save!
    #user_being_subscribed_to
    user_subscribed_to_user_denormalized_stat = ::UserDenormalizedStat.where(user_id: @user_subscription.to_user_id).first
    user_subscribed_to_user_denormalized_stat.updater_service.increment_subscribers_count(-1)
    user_subscribed_to_user_denormalized_stat.save!
  end

  def subtract_karmas_of_both_users
    @current_user.user_karma.updater.add_for_unsubscription_to_user
    @current_user.user_karma.save!

    @user_subscription.to_user.user_karma.updater.add_when_user_unsubscribed_from_this_user
    @user_subscription.to_user.user_karma.save!
  end


  def resolve_success
    publish :ok, @user_subscription
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordNotFound
      publish :record_not_found
    else
      raise e
    end

  end

end
