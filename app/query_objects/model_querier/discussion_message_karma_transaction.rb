class ModelQuerier::DiscussionMessageKarmaTransaction

  def initialize(qo = false)
    @qo = qo
  end

  def self.qo
    ::DiscussionMessageKarmaTransaction
  end

  def self.index_for_cu_with_post_karma_ids(current_user_id:, discussion_message_karma_transaction_ids:)
    qo.where('user_id = ? and discussion_message_karma_id in (?)', current_user_id, discussion_message_karma_transaction_ids)
  end

end
