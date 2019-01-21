class DiscussionMessageKarma < Model

  register

  attributes :id, :count, :discussion_message_id

  has_one :discussion_message, class_name: 'DiscussionMessage'

  has_many :discussion_message_karma_transactions, class_name: 'DiscussionMessageKarmaTransaction'

  has_one :discussion_message_karma_transaction_for_cu, class_name: 'DiscussionMessageKarmaTransaction'

  def discussion_message_karma_transaction_for_cu_or_new
    if discussion_message_karma_transaction_for_cu
      self.discussion_message_karma_transaction_for_cu
    else
      self.discussion_message_karma_transaction_for_cu = DiscussionMessageKarmaTransaction.new(discussion_message_karma_id: self.id, user_id: CurrentUser.instance.id)
      discussion_message_karma_transaction_for_cu
    end
  end


end
