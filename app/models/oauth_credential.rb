class OauthCredential < ActiveRecord::Base

  #to be later used in validation
  #lists providers that are supported by app
  ALLOWED_PROVIDERS = ['developer']

  belongs_to :user

  include ModelValidator::CustomErrorable

  def validation_service
    @_validation_service ||= ::ModelValidator::OauthCredential.new(self)
  end

end
