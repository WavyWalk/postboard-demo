module Services
  class Oauth

    #To be used where coupling is not prefered
    #simply finds user or nil by omniauth_hash
    def self.find_and_return_user_if_exists(omniauth_hash)
      ::User.joins(:oauth_credentials)
        .where('oauth_credentials.provider = ? AND oauth_credentials.uid = ?', omniauth_hash['provider'], omniauth_hash['uid'])
        .first
    end


  end
end
