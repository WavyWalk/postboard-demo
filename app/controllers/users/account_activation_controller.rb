class Users::AccountActivationController < ApplicationController

  def create

    cmpsr = ComposerFor::User::ActivateAccountFromLoginToken.new(false, params, self)  

    cmpsr.when(:ok) do |user|
      
      log_in user
      remember user
      redirect_to root_url
    
    end 

    cmpsr.when(:unauthorized) do
      head 403 and return
    end
    
    cmpsr.run
  end

end
