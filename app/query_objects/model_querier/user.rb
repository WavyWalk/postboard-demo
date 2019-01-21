class ModelQuerier::User

  @qo = ::User

  def self.get_by_ids(ids)
    @qo.where(id: ids)
  end

  def self.get_by_ids_with_karmas(ids)
    @qo.where(id: ids).includes(:user_karma)
  end


  def self.users_show_general_info(user_id)
    @qo.where(id: user_id).includes(:user_karma, :uc_s_name).first
  end

  def self.post_count_for(user_id)
    ::Post.where(author_id: user_id).count
  end

  def self.ping_current_user_json(current_user)
    if current_user
      current_user.as_json(only: [:id, :registered], include: [{user_roles: {only: 'name'}}, {user_karma: {only: ["count", 'id']}}, {user_credential: {only: 'name'}}])
    else
      {}
    end
  end


end
