class ModelQuerier::Discussion

  @qo = ::Discussion

  def self.show_by_post_id(post_id)
    @qo
      .where(discussable_id: post_id, discussable_type: 'Post')
      .includes(discussion_messages: [:discussion_message_karma]).first
  end

end
