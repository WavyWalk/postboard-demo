class ComposerFor::User::Create::TransferFromGuest < ComposerFor::Base

  # =========>       WARNING:  <=======
  #changing flow of this composer can break ComposerFor::User::CreateFromOauth
  #because it calls this composer in it's compose, so changes in here
  #should be compatible with that cmpsr. Or that composer will need to be
  #refactored to not depend on this composer.



  def initialize(model:, params:, controller: false, options: {})
    @user = model
    @unpermitted_params = params
    @controller = controller
    @options = options
  end


  def before_compose
    permit_attributes
  end


  def permit_attributes
    @user_credential_attributes =  @unpermitted_params.require(
      :user
    ).require(
      :user_credential
    ).permit(
      :password, :password_confirmation, :email, :name
    )
    
  end


  def assign_attributes
    @user_credential = @user.user_credential || UserCredential.new
    @user_credential.assign_attributes @user_credential_attributes
    @user.user_credential = @user_credential

    @user_credential.email.downcase! if @user_credential.email
    @user_credential.auth_service.generate_and_set_login_token

    if !((x = @user_credential_attributes[:password]).blank?)
      @user_credential.password_digest = UserCredential.auth_service.digest(x)
    end

  end


  def validate_user_credential

    #this composer can be called from ComposerFor::User::CreateFromOauth
    #if create scenario called password or email must be provided
    #but from oauth able to not have those values
    unless @options[:from_create_from_oauth_composer]
      @user_credential
        .validating_service
        .set_scenarios(:create)
        .validate
    else
      @user_credential
        .validating_service
        .set_scenarios(:create_from_oauth)
        .validate
    end
  end


  def set_user_as_registered_depending_on_data_provided
    if @user_credential.email || @user_credential.password
      @user.registered = true
    end
  end

  def copy_name_from_credential_to_user
    @user.name = @user_credential.name
  end


  def compose
    
    assign_attributes
    copy_name_from_credential_to_user
    validate_user_credential
    set_user_as_registered_depending_on_data_provided
    @user.save!
    @user_credential.save!
    update_roles
    @user.save!
    
  end


  def update_roles

    @user.role_service.destroy_user_role_link_to_role_with_name('guest')

    if !@user.user_credential.name.blank?
      @user.role_service.destroy_user_role_link_to_role_with_name('no_name')
      @user.role_service.add_role('name_provided')
    end

    if !@user.user_credential.email.blank?
      @user.role_service.destroy_user_role_link_to_role_with_name('no_email')
      @user.role_service.add_role('email_provided')
    end

    if !@user.user_credential.email.blank? || !@user.user_credential.password.blank?
      @user.role_service.destroy_user_role_link_to_role_with_name('no_e_or_p')
    end

    @user.registered = true

  end


  def resolve_success
    publish(:ok, @user)
  end


  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      byebug
      publish(:validation_error, @user)
    else
      raise e
    end

  end

end
