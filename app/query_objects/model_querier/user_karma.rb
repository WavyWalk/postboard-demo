class ModelQuerier::UserKarma

  @qo = ::UserKarma

  class << self
    
    def find_by_joined_post_karma_id(post_karma_id)
      @qo.joins(user: [posts: [:post_karma]]).where('post_karmas.id = ?', post_karma_id)
    end

    def find_by_joined_post_id(post_id)
      @qo.joins(user: [:posts]).where('posts.id = ? ', post_id).first
    end
    
    def find_by_joined_discussion_message_id(discussion_message_id)
      @qo.joins(user: [:discussion_messages]).where('discussion_messages.id = ?', discussion_message_id).first
    end

  end

end