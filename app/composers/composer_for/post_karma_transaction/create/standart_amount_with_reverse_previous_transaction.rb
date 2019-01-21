class ComposerFor::PostKarmaTransaction::Create::StandartAmountWithReversePreviousTransaction < ComposerFor::Base

  def initialize(
    post_karma_transaction:, controller:, 
    post_karma:, recieving_user_karma:,
    permitted_attributes:,
    current_user_karma:
  )
    #MODEL COMES PREVALIDATED (CUSTOM VALIDATOR)
    @post_karma_transaction = post_karma_transaction
    @controller = controller
    @post_karma = post_karma
    @recieving_user_karma = recieving_user_karma
    @permitted_attributes = permitted_attributes
    @current_user_karma = current_user_karma
  end

  def before_compose
    assign_new_attributes_to_post_karma_transaction
    ammend_post_karma
    ammend_recieving_user_karma
  end


  def assign_new_attributes_to_post_karma_transaction
    @post_karma_transaction.amount = @permitted_attributes['amount']
  end


  def ammend_post_karma
    amount = @permitted_attributes['amount']

    if amount == 1
      @post_karma.increment(:count, 2)
      @post_karma.increment(:count_u, 1)
      @post_karma.increment(:count_d, -1)
    else
      @post_karma.increment(:count, -2)
      @post_karma.increment(:count_u, -1)
      @post_karma.increment(:count_d, 1)
    end

    @post_karma = ::Services::PostKarma::ComposerHelpers.refine_hot_since(@post_karma)
  end


  def ammend_recieving_user_karma    
    amount = @post_karma_transaction.amount
    @recieving_user_karma.set.when_this_users_post_like_or_dislike_reversed(amount) 

    record_recieving_user_karma_event
  end


  def record_recieving_user_karma_event
    ::Services::DayKarmaEvent::Factory.when_this_users_post_like_or_dislike_reversed(
      user_id: @recieving_user_karma.user_id, 
      amount: @post_karma_transaction.amount, 
      post_id: @post_karma.post_id, 
      source_text: @post_karma.post.title
    )
  end


  def compose
    @post_karma.save!
    @post_karma_transaction.save!
    @recieving_user_karma.save!    
  end

  def resolve_success
    #frontend will take this value to render like or dislike
    @post_karma_transaction.amount = @permitted_attributes['amount'].to_i
    publish(:ok, @post_karma_transaction)
  end

  def resolve_fail(e)
    
    case e
    when e
      raise e    
    else
      raise e
    end

  end

end
