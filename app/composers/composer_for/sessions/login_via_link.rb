class ComposerFor::Sessions::LoginViaLink < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @unpermitted_params = params
    @controller = controller
    @options = options
  end

  def before_compose
    @login_token = @unpermitted_params[:id]
    @email = @unpermitted_params[:email]
  end

  def compose
    
    @user_credential = UserCredential.find_by!(email: @email)

    if @user_credential.matches_digested?(:login_token_digest, @login_token)
      @user = @user_credential.user
    else
      fail_immediately("token doesn't match")
    end      

  end

  def resolve_success
    publish(:ok, @user)
  end

  def resolve_fail(e)
    case e
    when ActiveRecord::RecordNotFound
      raise e
    else
      raise e
    end

  end

end
