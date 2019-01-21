class Permissions::Users::AvatarRules < Permissions::Base

  def update(user_id:)
    if @current_user && @current_user.id.to_s == user_id
      return true
    end
  end

end
