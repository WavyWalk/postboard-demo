class ComposerFor::UserSubscription::Create < ComposerFor::Base

  def initialize(params:, current_user:)
    @params = params
    @current_user = current_user
  end

  def before_compose
    set_unsaved_user_subscription
    permit_attributes
    assign_attributes
    check_if_subscription_already_exists!
    validate
  end

  def set_unsaved_user_subscription
    @unsaved_user_subscription = ::UserSubscription.new
  end

  def permit_attributes
    @permitted_params = @params.require(:user_subscription).permit(:to_user_id)
  end

  def assign_attributes
    @unsaved_user_subscription.to_user_id = @permitted_params[:to_user_id]
    @unsaved_user_subscription.user_id = @current_user.id
  end

  def check_if_subscription_already_exists!
    if ::UserSubscription.where(user_id: @unsaved_user_subscription.user_id, to_user_id: @unsaved_user_subscription.to_user_id).first
      fail_immediately(:subscription_already_exists)
    end
  end

  def validate
    validator = @unsaved_user_subscription.validation_service.set_scenarios(:create)
    validator.validate
  end

  def compose
    if @unsaved_user_subscription.save!
      @saved_user_subscription = @unsaved_user_subscription
      update_denormalized_user_stats
    end
    reward_users_with_karma
  end

  def update_denormalized_user_stats
    #subscribing_user
    subscribing_user_denormalized_stat = ::UserDenormalizedStat.where(user_id: @saved_user_subscription.user_id).first
    subscribing_user_denormalized_stat.updater_service.increment_subscriptions_count(1)
    subscribing_user_denormalized_stat.save!
    #user_being_subscribed_to
    user_subscribed_to_user_denormalized_stat = ::UserDenormalizedStat.where(user_id: @saved_user_subscription.to_user_id).first
    user_subscribed_to_user_denormalized_stat.updater_service.increment_subscribers_count(1)
    user_subscribed_to_user_denormalized_stat.save!
  end

  def reward_users_with_karma
    @current_user.user_karma.updater.add_for_subscription_to_user
    @current_user.user_karma.save!

    @saved_user_subscription.to_user.user_karma.updater.add_when_user_subscribed_to_this_user
    @saved_user_subscription.to_user.user_karma.save!
  end

  def resolve_success
    publish :ok, @saved_user_subscription
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      publish :validation_error, @unsaved_user_subscription
    when :subscription_already_exists
      publish :subscription_already_exists
    else
      raise e
    end

  end

end
