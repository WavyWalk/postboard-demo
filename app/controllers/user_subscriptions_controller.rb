class UserSubscriptionsController < ApplicationController

  def create

    build_permissions UserSubscription

    authorize! @permission_rules.create
    #AUTh

    cmpsr = ComposerFor::UserSubscription::Create.new(params: params, current_user: current_user)

    cmpsr.when(:ok) do |user_subscription|
      render json: user_subscription.as_json
    end

    cmpsr.when(:validation_error) do |user_subscription|
      render json: user_subscription.as_json
    end

    cmpsr.when(:subscription_already_exists) do
      render json: {errors: {general: ['subscription_already_exists']}}
    end

    cmpsr.run

  end





  def destroy

    build_permissions UserSubscription

    authorize! @permission_rules.destroy

    cmpsr = ComposerFor::UserSubscription::Destroy.new(params: params, current_user: current_user)


    cmpsr.when(:ok) do |user_subscription|
      render json: user_subscription
    end


    cmpsr.when(:current_user_is_not_owner_of_subcsription) do
      render json: {errors: {general: ['permission_denied']}}
    end

    cmpsr.when(:record_not_found) do
      render json: {errors: {general: ['permission_denied']}}
    end

    cmpsr.run

  end

  


  def index_for_user

    build_permissions ::UserSubscription  

    authorize! @permission_rules.index_for_user

    user_subscriptions = ::UserSubscription.qo.where_subscribing_user(user_id: params[:id])

    render json: AsJsonSerializer::UserSubscription::IndexForUser.new(
                   user_subscriptions
                 ).success

  end



end
