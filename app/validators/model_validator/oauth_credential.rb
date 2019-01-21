class ModelValidator::OauthCredential < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}

  def create_scenario
    set_attributes :uid, :provider, :uniqness_by_uid_and_provider
  end



  def uid
    should_present
  end


  def provider
    should_present
    should_be_in(target_array: OauthCredential::ALLOWED_PROVIDERS)
  end


  def uniqness_by_uid_and_provider

    _provider = @model.provider
    _uid = @model.uid

    oauth_credential_not_existent = OauthCredential.where(provider: _provider, uid: _uid).first
    byebug
    unless oauth_credential_not_existent
      true
    else
      add_error(:provider, "uid and provider pair already exists")
    end

  end


end
