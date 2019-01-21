class UserCredential < ActiveRecord::Base


  include ModelValidator::CustomErrorable
  #AUTHENTICATION
  #ASSOCIATIONS
  belongs_to :user
  #END ASSOCIATIONS

  attr_accessor :login_token, :password, :password_confirmation, :remember_token


  #END AUTHENTICATION
  
  def validating_service(options = {})
    @_validating_service ||= ModelValidator::UserCredential.new(self, options)
  end

  def auth_service
    @_auth_service ||= UserSubClassServices::Auth.new(self)
  end

  def self.auth_service
    UserSubClassServices::Auth
  end


end
