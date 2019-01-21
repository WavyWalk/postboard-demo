class ComposerFor::Sessions::SendLoginLink < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @unpermitted_params = params
    @controller = controller
    @options = options
  end

  def compose

    @model = UserCredential.find_by!(email: @unpermitted_params[:user][:user_credential][:user_credential][:email]).user
    
    check_if_activated!
    
    generate_and_set_login_token!

    send_login_link_email
    
  end

  def resolve_success
    publish(:ok, @model)
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordNotFound 
      publish(:not_found)
    when :accont_not_activated
      publish(:account_not_activated, @model)
    else
      raise e
    end

  end

private
  
  def check_if_activated!
    if !@model.registered && @model.user_credential.try(:email)
      
      @model.user_credential.errors.add(:email, "you haven't activated your account")
      
      fail_immediately(:account_not_activated)
    end
  end

  def generate_and_set_login_token!
    @model.user_credential.login_token = UserCredential.auth_service.generate_token
    @model.user_credential.login_token_digest = UserCredential.auth_service.digest(@model.user_credential.login_token)
    @model.user_credential.save!
  end

  def send_login_link_email
    UserMailer.login_link_email(@model, @model.user_credential.login_token).deliver_later
  end

end
