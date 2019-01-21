class DiscussionMessageKarmaTransaction < Model

  register

  attr_accessor :previous_amount

  attributes :id, :amount, :user_id, :discussion_message_karma_id, :cancel_type, :user_change_amount

  has_one :discussion_message_karma, class_name: 'DiscussionMessageKarma'
  has_one :user, class_name: 'User'


  route :create, { post: 'discussion_message_karma_transactions' }

  route :Index_for_cu, { get: 'discussion_message_karma_transactions/index_for_cu' }

  def self.after_route_index_for_cu(r)
    self.after_route_index(r)
  end

  def amount_change_factor
    return amount unless previous_amount
    #no change
    if amount == previous_amount
      0
    #cancel previous
    elsif (amount == 0) && (previous_amount != 0)
      previous_amount * -1
    #reverse
    elsif ((amount < 0) != (previous_amount < 0)) && previous_amount != 0
      amount * 2
    else
      amount
    end
  end 


end
