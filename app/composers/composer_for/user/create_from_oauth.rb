class ComposerFor::User::CreateFromOauth < ComposerFor::Base

  #TODO: HANDLE UNUNIQNES OF NAME: should prompt for name

  def initialize(omniauth_hash:, controller:, params:)
    @omniauth_hash = omniauth_hash
    @controller = controller
    @params = params
  end

  def before_compose
    set_params_from_omniauth_hash_to_pass_it_to_transfer_to_guest_cmpsr
    set_user
  end


  #To not rewrite logic of promotion from guest (user with guest role anyway created on visit)
  #this composer will simply mock params from omnihash and after that composer is done will continue
  #and do logic related to omniauth only *(handle oauth credential)
  def set_params_from_omniauth_hash_to_pass_it_to_transfer_to_guest_cmpsr
    @params_from_omniauth_for_transfer_to_guest_cmpsr = pick_fields_from_omniauth_hash_that_will_be_passed_to_transfer_guest_cmpsr_as_params
  end


  def pick_fields_from_omniauth_hash_that_will_be_passed_to_transfer_guest_cmpsr_as_params
    #TODO: implement picks depending on provider because some of them may return emails for example, and etc
    #TODO: REFACTOR TransferFromGuest COMPOSER TO RECIEVE USER CREDENTIAL PREPERMITTED
    hash_to_return = {'user' => {'user_credential' => {}}}
    hash_to_return['user']['user_credential']['name'] = @omniauth_hash['info']['name']
    hash_to_return = pick_fields_from_omniauth_hash_depending_on_provider(hash_to_return)

    return ActionController::Parameters.new(hash_to_return)

  end

  def pick_fields_from_omniauth_hash_depending_on_provider(hash_to_return)
    # case @omniauth_hash['provider']
    #
    # when #someprovider provides for e.g. email
    #   hash_to_return['email'] = @omniauth_hash['info_where_email']['email']
    # end
    hash_to_return
  end


  def set_user
    @user = @controller.current_user
  end



  def compose
    cmpsr = ::ComposerFor::User::Create::TransferFromGuest.new(
      model: @user,
      params: @params_from_omniauth_for_transfer_to_guest_cmpsr,
      options: {from_create_from_oauth_composer: true}
    )

    cmpsr.when(:ok) do |user|
      @user = user
      compose_block_continuation_when_transfer_from_guest_published_ok
    end

    cmpsr.when(:validation_error) do |user|
      @user = user
      fail_immediately(:validation_error)
    end

    cmpsr.run
  end



  def compose_block_continuation_when_transfer_from_guest_published_ok
    set_and_initialize_oauth_credential_for_user
    assign_attributes_for_oauth_credential
    validate_oauth_credential
    save_oauth_credential!
    #@user.save! #for now this composer doesn't change @user; TransferFromGuest handles it and saves!
  end


  def set_and_initialize_oauth_credential_for_user
    @oauth_credential = OauthCredential.new
  end


  def assign_attributes_for_oauth_credential
    case @omniauth_hash['provider']

    when 'developer'
      @omniauth_hash['uid'] = SecureRandom.hex(64)
    end
    @oauth_credential.uid = @omniauth_hash['uid']
    @oauth_credential.provider = @omniauth_hash['provider']
    @oauth_credential.user_id = @user.id
  end


  def validate_oauth_credential
    @oauth_credential
      .validation_service
      .set_scenarios(:create)
      .validate
  end


  def save_oauth_credential!
    @oauth_credential.save!
  end


  def resolve_success
    publish(:ok, @user)
  end



  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      byebug
      publish(:validation_error, @user)
    when :validation_error
      byebug
      publish(:validation_error, @user)
    else
      raise e
    end

  end

end
