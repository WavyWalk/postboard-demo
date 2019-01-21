##########################AUTHENTICATION
module SessionsHelper

  def log_in(user)

    cookies['jwt'] = {
      :value    => Services::Jwt.encode(user),
      :httponly => true
    }

  end

  def current_user

    if (id = id_from_decoded_authorization_token)

      @current_user ||= User.find_by(id: id)

    # elsif (user_id = cookies.signed[:user_id])
    #
    #   user = User.find_by(id: user_id)
    #   user_credential = user.try(:user_credential)
    #
    #   if user_credential && user_credential.auth_service.matches_digested?(:remember_token_digest, cookies[:remember_token])
    #
    #     log_in user
    #     @current_user = user
    #
    #   end

    end

  end

  def current_user_registered?

    if current_user.try(:registered)
      self.current_user
    end

  end

  def logged_in?
    current_user
  end

  def forget(user)

    cookies.delete('jwt')
    # user.user_credential.auth_service.clear_remember_token_digest
    # cookies.delete(:user_id)
    # cookies.delete(:remember_token)

  end

  def log_out

    forget(current_user)
    cookies.delete('jwt')
    @current_user = false

  end

  def remember(user)

    cookies['jwt'] = {
      :value    => Services::Jwt.encode(user),
      :httponly => true,
      :expires  => 20.years.from_now
    }
    # user.user_credential.auth_service.update_remember_token_digest
    #
    # cookies.permanent.signed[:user_id] = user.id
    # cookies.permanent[:remember_token] = user.user_credential.remember_token

  end

  def current_user?(user)

    user == current_user

  end

  #used as before_action filter
  def require_logged_in_user
    if !current_user
      head 403
    end
  end

  def authorization_token

    cookies['jwt']
    # if request.headers['Authorization'].present?
    #   request.headers['Authorization'].split(' ').last
    # end

  end

  def decoded_authorization_token
    @decoded_authorization_token ||= (token = Services::Jwt.decode(authorization_token)) ? token : HashWithIndifferentAccess.new({})
  end

  def id_from_decoded_authorization_token
    decoded_authorization_token['id']
  end


end



##########################END AUTHENTICATION
