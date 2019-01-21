class ComposerFor::User::Update < ComposerFor::Base

  def initialize(current_user:, params:, controller:)
    
    @current_user = current_user
    @unpermitted_params = params
    @controller = controller
  end


  def before_compose
    permit_attributes
    prepare_user_credential
    set_what_to_update
    assign_attributes_depending_on_whats_changed
    validate_updated_user_credential
  end


  def permit_attributes
    @user_credential_attributes =  @unpermitted_params.require(
      :user
    ).require(
      :user_credential
    ).permit(
      :password, :password_confirmation, :email, :name, :old_password
    )
  end


  def prepare_user_credential
    @current_user.user_credential.password = @user_credential_attributes['password']
    @current_user.user_credential.password_confirmation = @user_credential_attributes['password_confirmation']
  end


  def set_what_to_update
    @what_to_update = {
      name: name_changed?,
      email: email_changed?,
      password: password_changed?,
      first_time_email: first_time_email?,
      first_time_password: first_time_password?
    }
  end


  def name_changed?
    !@user_credential_attributes[:name].blank? && (@current_user.user_credential.name != @user_credential_attributes[:name])
  end


  def email_changed?
    !@user_credential_attributes[:email].blank? && ( !@current_user.user_credential.email.blank? && (@current_user.user_credential.email != @user_credential_attributes[:email]) )
  end


  def first_time_email?
    !@user_credential_attributes[:email].blank? && @current_user.user_credential.email.blank?
  end


  def password_changed?
    #!@user_credential_attributes[:password].blank? && ( @current_user.user_credential.password_digest && !(@current_user.user_credential.auth_service.matches_digested?(:password_digest, @user_credential_attributes[:password]))  )
    !@user_credential_attributes[:old_password].blank?
  end


  def first_time_password?
    !@user_credential_attributes[:password].blank? && @current_user.user_credential.password_digest.blank?
  end


  def assign_attributes_depending_on_whats_changed

    if @what_to_update[:name]
      raise "name update not_implemented #{self.class.name}#assign_attributes_depending_on_whats_changed"
      #@current_user.user_credential.name = @user_credential_attributes[:name]
    end

    if @what_to_update[:email]
      raise "email update not_implemented #{self.class.name}#assign_attributes_depending_on_whats_changed"
    end

    if @what_to_update[:first_time_email]
      @current_user.user_credential.email = @user_credential_attributes[:email]
    end

    if @what_to_update[:first_time_password]
      @current_user.user_credential.password_digest = UserCredential.auth_service.digest(@user_credential_attributes[:password])
    end

    if @what_to_update[:password] && !@what_to_update[:first_time_password]
      
      if @current_user.user_credential.auth_service.matches_digested?(:password_digest, @user_credential_attributes[:old_password])
        @current_user.user_credential.password_digest = UserCredential.auth_service.digest(@user_credential_attributes[:password])
      else
        @current_user.user_credential.add_custom_error(:old_password, 'old password is incorrect')
      end
    end

  end


  def validate_updated_user_credential
    attributes_to_validate = []

    @what_to_update.each do |k,v|
      if v
        attributes_to_validate << k
      end
    end

    validator = @current_user
      .user_credential
      .validating_service
      .set_attributes(*attributes_to_validate)
      .validate
  end


  def compose

    @current_user.user_credential.save!

    alter_roles_depending_on_whats_changed

  end


  def alter_roles_depending_on_whats_changed
    if @what_to_update[:first_time_email]
      @current_user.role_service.destroy_user_role_link_to_role_with_name('no_email')
      @current_user.role_service.add_role('email_provided')
    end

    if @what_to_update[:first_time_email] || @what_to_update[:first_time_password]
      @current_user.role_service.destroy_user_role_link_to_role_with_name('no_e_or_p')
    end
  end


  def resolve_success
    
    publish :ok, @current_user
  end


  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish :validation_error, @current_user
    else
      raise e
    end

  end


end
