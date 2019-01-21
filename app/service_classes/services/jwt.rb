class Services::Jwt

  def self.encode(user)
    raise "#{self.class.name}.encode arg user is invalid" if (!user || !user.id)
    value_to_encode = {id: user.id, t: Time.now.to_i}
    ::JWT.encode(value_to_encode, Rails.application.secrets.secret_key_base, 'HS256')
  end

  def self.encode_hash(hash)
    ::JWT.encode(hash, Rails.application.secrets.secret_key_base, 'HS256')
  end

  def self.decode(token)
    HashWithIndifferentAccess.new ::JWT.decode(token, Rails.application.secrets.secret_key_base, true, {:algorithm => 'HS256'})[0]
    rescue
    false
  end

  def self.refresh(token)
    decoded_token = self.decode(token)
    decoded_token['t'] = Time.now
    encode_hash(decoded_token)
  end

end
