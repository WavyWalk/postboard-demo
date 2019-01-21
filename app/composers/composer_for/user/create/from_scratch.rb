class ComposerFor::User::Create::FromScratch < ComposerFor::Base




  def initialize(options: {}, model:, params:, controller:)
    byebug
    @model = model #recieves User.new
    @unpermitted_params = params
    @controller = controller
    @options = options
  end







  def before_compose

    set_user_credential_attributes_var

    build_and_assign_user_credential

    validate_user_credential

    set_user_registered_if_password_provided

    build_user_karma

    build_user_denormalized_stat

  end







  def set_user_credential_attributes_var

    @user_credential_attributes =  @unpermitted_params.require(
        :user
      ).require(
        :user_credential
      ).permit(
        :password, :password_confirmation, :email, :name
      )

  end





  #sets @user_credential
  def build_and_assign_user_credential

    @model.user_credential = @user_credential = UserCredential.new(@user_credential_attributes)

    @user_credential.email.downcase! if @user_credential.email

    @user_credential.auth_service.generate_and_set_login_token

    if x = @user_credential_attributes[:password]
      @user_credential.password_digest = UserCredential.auth_service.digest(x)
    end

  end







  def validate_user_credential

    @user_credential
      .validating_service
      .set_scenarios(:create)
      .validate

  end


  def set_user_registered_if_password_provided

    if @has_password
      @model.registered = true
    end

  end


  def build_user_karma
    @model.user_karma = UserKarma.new(count: 0)
  end


  def build_user_denormalized_stat
    @model.user_denormalized_stat = UserDenormalizedStat.new
  end


  def compose

    @model.save! #validates_associated is set on User for :user_credential so it will validate it


  end







  def after_compose
    if @user_credential.email
      UserMailer.account_activation_email(@model, @user_credential.login_token).deliver_later
    end
  end






  def resolve_success
    byebug
    publish(:ok, @model)
  end





  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @model)
    else
      raise e
    end

  end

end
