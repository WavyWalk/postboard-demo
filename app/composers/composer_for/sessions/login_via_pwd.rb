class ComposerFor::Sessions::LoginViaPwd < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})

    @params = params
    @controller = controller
    @options = options

    @compose_without_transaction = true

  end

  def before_compose
    short_cut_params
  end

  def short_cut_params
    @user_credential_params = @params['user']['user_credential']
  end

  def compose

    check_if_password_and_email_provided!

    find_credential!

    check_if_password_ok!

  end

  #NAME CAN ALSO BE PASSED IN EMAIL FIELD!!!!!!
  def check_if_password_and_email_provided!

    unless @user_credential_params[:email].blank? || @user_credential_params[:password]
      fail_immediately(:no_email_or_pwd_provided)
    end

  end






  def find_credential!
    if @user_credential = UserCredential.where(email: @user_credential_params[:email]).first
      return
    elsif @user_credential = UserCredential.where(name: @user_credential_params[:email]).first
      return
    else
      raise ActiveRecord::RecordNotFound
    end
  end






  def check_if_password_ok!
    unless @user_credential && @user_credential.auth_service.matches_digested?(:password_digest, @user_credential_params[:password])
      fail_immediately(:unauthorized)
    end
  end






  def resolve_success
    publish(:ok, @user_credential.user)
  end

  def resolve_fail(e)

    case e

    when :no_email_or_pwd_provided
      publish(e)

    when ActiveRecord::RecordNotFound
      publish :unauthorized

    when :unauthorized
      publish :unauthorized

    else
      raise e
    end

  end

end
