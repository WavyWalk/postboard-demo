class ComposerFor::User::ActivateAccountFromLoginToken < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @unpermitted_params = params
    @controller = controller
    @options = options
  end

  def before_compose
    @login_token = @unpermitted_params[:id]
  end

  def compose
    find_credential_and_match_token
  end

  def resolve_success
    publish(:ok, @user)
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordNotFound
      publish(:unauthorized)
    when 'immediate_fail'
      publish(:unauthorized)
    else
      raise e
    end

  end

private

 def find_credential_and_match_token

   @user_credential = UserCredential.find_by!(email: @unpermitted_params[:email])

   if @user_credential.auth_service.matches_digested?(:login_token_digest, @login_token)

     @user = @user_credential.user

     @user.registered = true
     @user.save!

     @user.user_credential.login_token_digest = nil
     @user.user_credential.save!

   else

     fail_immediately("token doesn't match")

   end

 end

end
