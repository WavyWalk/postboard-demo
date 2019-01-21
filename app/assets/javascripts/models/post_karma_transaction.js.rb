class PostKarmaTransaction < Model

  register

  attr_accessor :previous_amount

  attributes :id, :amount, :user_id, :post_karma_id, :cancel_type, :user_change_amount

  has_one :post_karma, class_name: 'PostKarma'
  has_one :user, class_name: 'User'

  route :create, { post: 'post_karma_transactions' }

  #for cases when like is reversed amount should be 2 for another karma calculations
  #so it acts as quoeficient
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
