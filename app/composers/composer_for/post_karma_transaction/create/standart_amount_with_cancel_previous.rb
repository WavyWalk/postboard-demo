class ComposerFor::PostKarmaTransaction::Create::StandartAmountWithCancelPrevious < ComposerFor::Base

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
    ammend_post_karma
    ammend_recieving_user_karma
    cancel_current_user_previous_karma_addition_for_post_like_or_dislike
    assign_values_on_transaction_for_frontend
  end


  def ammend_post_karma
    new_amount = @permitted_attributes['amount']
    #if user liked what was liked this like is cancelled
    #so plainly it cancels all previous increments
    if new_amount == 1
      @post_karma.increment(:count, -1)
      @post_karma.increment(:count_u, -1)
    else
      @post_karma.increment(:count, 1)
      #count_d is absoulute num
      @post_karma.increment(:count_d, -1)
    end
    
    @post_karma = ::Services::PostKarma::ComposerHelpers.refine_hot_since(@post_karma)
  end


  def ammend_recieving_user_karma
    amount = @permitted_attributes['amount']
    @recieving_user_karma.set.when_this_users_post_like_or_dislike_cancelled(amount) 

    record_recieving_user_karma_event(amount)
  end


  def record_recieving_user_karma_event(amount)
    ::Services::DayKarmaEvent::Factory.when_this_users_post_like_or_dislike_cancelled(
      user_id: @recieving_user_karma.user_id, 
      amount: amount, 
      post_id: @post_karma.post_id, 
      source_text: @post_karma.post.title
    )
  end


  def cancel_current_user_previous_karma_addition_for_post_like_or_dislike
    post_is_hot = @post_karma.is_hot?
    
    @current_user_karma.updater.when_cancelled_previous_like_or_dislike(post_is_hot: post_is_hot)
    @current_user_karma.save

    record_day_karma_event_when_post_like_or_dislike_cancelled(@current_user_karma, post_is_hot)
  end

  def record_day_karma_event_when_post_like_or_dislike_cancelled(user_karma, post_is_hot)
    ::Services::DayKarmaEvent::Factory.when_post_like_or_dislike_cancelled(
      user_id: user_karma.user_id,
      post_id: @post_karma.post_id,
      source_text: @post_karma.post.title,
      post_is_hot: post_is_hot
    )
  end


  def assign_values_on_transaction_for_frontend
    @user_change_amount = nil
  
    if @post_karma.is_hot?
      @user_change_amount = -UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED
    else
      @user_change_amount = -UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED
    end
    #client depends on amount to render whether like or disliked
    @post_karma_transaction.amount = 0
    #this is attr_accessor serves for frontend to render updated karma without fetching
    @post_karma_transaction.user_change_amount = @user_change_amount
  end


  def compose
    @post_karma.save!
    @post_karma_transaction.destroy!
    @recieving_user_karma.save!
    @current_user_karma.save!
  end


  def resolve_success
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
