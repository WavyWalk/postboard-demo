class Services::User::Updater

  def initialize(owner)
    @owner = owner
  end

  def serialize_avatar_to_s_avatar_and_save!
    if @owner.avatar
      to_serialize = {}
      to_serialize[:thumb_url] = @owner.avatar.url(:thumb)
      to_serialize[:medium_url] = @owner.avatar.url(:medium)
      @owner.s_avatar = to_serialize.to_json
    else
      @owner.s_avatar = {}.to_json
    end
    @owner.save!
  end

  def reserialize_avatar_if_any!
    serialize_avatar_to_s_avatar_and_save!
  end

end
