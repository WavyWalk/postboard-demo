class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create_or_login_from_oauth_provider]

  def create

    cmpsr = ComposerFor::User::Create::BuildComposer
              .new(self)
              .create

    cmpsr.when(:ok) do |user|

      user.reload

      serialized_user = user.as_json(
        {
          only:
          [
            :id, :registered, :s_avatar
          ],
          include:
          [
            {
              user_roles:
              {
                only:
                [
                  :name
                ]
              }
            },
            {
              user_credential:
              {
                only:
                [
                  :email,
                  :name
                ]
              }
            }
          ]
        }
      )

      render json: serialized_user

    end

    cmpsr.when(:validation_error) do |user|
      render json: user.as_json(only: [:id], methods: [:errors], include: [{user_credential: {only: [:email], methods: [:errors]}}])
    end

    cmpsr.run

  end





  def ping_current_user

    if current_user

      serialized_user = current_user.as_json(
        include: [
          {user_roles: {only: ['id', 'name']}}, 
          {user_karma: {only: ["count", 'id']}}, 
          {user_credential: {only: ['name', 'email']}}]
      )
      
      if params['include_notifications']
       notifications = current_user.notifications        
       serialized_user['notifications'] = notifications.as_json
      end
      
      if !current_user.user_credential.password_digest.blank?
        serialized_user['has_password'] = true
      end

      render json: serialized_user
    else
      render json: {}
    end

  end


  #redirected to this path from provider
  #serves for oath login/user_creation
  def create_or_login_from_oauth_provider

    omniauth_hash = request.env['omniauth.auth']

    if user = ::Services::Oauth.find_and_return_user_if_exists( omniauth_hash )
      log_in( user )
    else
      initiate_composer_for_user_create_from_oauth( omniauth_hash )
    end

  end

  #to be called in action, prepares composer and attaches callbacks to be called
  #when composer is done. serves for user creation from auth
  def initiate_composer_for_user_create_from_oauth(omniauth_hash)

    cmpsr = ::ComposerFor::User::CreateFromOauth.new(omniauth_hash: omniauth_hash, controller: self, params: params)

    cmpsr.when(:ok) do |user|
      log_in user
    end

    cmpsr.when(:validation_error) do |user|
      #should set sort of var and render it in view with errors
      raise "NOT IMPLEMENTED"
    end

    cmpsr.run

  end


end
