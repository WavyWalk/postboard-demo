class Users::AvatarsController < ApplicationController

  def update
    permissions = Permissions::Users::AvatarRules.new(User, self)
    authorize! permissions.update(user_id: params['user_id'])

    cmpsr = ComposerFor::Users::Avatars::Update.new(params, self)

    cmpsr.when(:ok) do |s_avatar|
      render json: AsJsonSerializer::Users::Avatars::Update.new(s_avatar).success
    end

    cmpsr.when(:validation_error) do |s_avatar|
      render json: AsJsonSerializer::Users::Avatars::Update.new(s_avatar).error
    end

    cmpsr.run

  end

end
