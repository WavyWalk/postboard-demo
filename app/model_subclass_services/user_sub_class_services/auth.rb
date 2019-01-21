class UserSubClassServices::Auth

  def initialize(owner)
    @owner = owner
  end


  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.generate_token
    SecureRandom.urlsafe_base64
  end


  def matches_digested?(attribute, token)

    digest = @owner.send(attribute)
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)

  end

  def update_remember_token_digest

    @owner.remember_token = self.class.generate_token
    @owner.update! remember_token_digest: self.class.digest(@owner.remember_token)

  end

  def update_login_token_digest
    @owner.login_token = self.class.generate_token
    @owner.update! login_token_digest: self.class.digest(@owner.login_token)
  end

  def clear_remember_token_digest

    @owner.update! remember_token_digest: nil

  end

  def generate_and_set_login_token
    @owner.login_token = self.class.generate_token
    @owner.login_token_digest = self.class.digest(@owner.login_token)
  end


end
