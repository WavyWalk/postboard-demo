class SessionsController < ApplicationController

  def send_login_link

    cmpsr = ComposerFor::Sessions::SendLoginLink.new(false, params, self)

    cmpsr.when(:ok) do |user|
      render json: user.as_json(only: [:id])
    end

    cmpsr.when(:not_found) do |user|
      render json: {user: {user_credential: {user_credential: {errors: {email: ['such email was not found']}}}}}
    end

    cmpsr.when(:account_not_activated) do |user|
      render json: {user: {user_credential: {user_credential: {errors: {general: ['account is not activated']}}}}}
    end

    cmpsr.run
  end

  def login_via_pwd

    cmpsr = ComposerFor::Sessions::LoginViaPwd.new(false, params, self)

    cmpsr.when(:ok) do |user|
      log_in user
      remember user
      render json: user.as_json(only: [:id])
    end

    cmpsr.when(:no_email_or_pwd_provided) do
      render json: {user_credential: {user_credential: {errors: {general: ['both email and password should be provided']}}}}
    end

    cmpsr.when(:unauthorized) do |user|
      render json: {user_credential:  {
                                              email: params[:user][:user_credential][:email],
                                              errors: {general: ['no such email or password is wrong']
                                             }
                                        }}
    end

    cmpsr.run

  end

  def login_via_link

    cmpsr = ComposerFor::Sessions::LoginViaLink.new(false, params, self)

    cmpsr.when(:ok) do |user|
      log_in user
      remember user
      redirect_to root_url
    end

    cmpsr.when(:not_found) do
      head 404
    end

    cmpsr.run

  end

  def logout
    log_out if logged_in?
    render json: {user: {}}
  end





end
