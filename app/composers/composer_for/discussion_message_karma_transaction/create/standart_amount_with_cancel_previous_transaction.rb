class ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmountWithCancelPreviousTransaction < ComposerFor::Base

  def initialize(
    discussion_message_karma_transaction:,
    controller:,
    discussion_message_karma:,
    recieving_user_karma:,
    permitted_attributes:,
    current_user_karma:
  )
    #MODEL COMES PREVALIDATED (CUSTOM VALIDATOR)
    @discussion_message_karma_transaction = discussion_message_karma_transaction
    @controller = controller
    @discussion_message_karma = discussion_message_karma
    @recieving_user_karma = recieving_user_karma
    @permitted_attributes = permitted_attributes
    @current_user_karma = current_user_karma
  end


  def before_compose
    ammend_discussion_message_karma
    ammend_recieving_user_karma
    cancel_current_user_previous_karma_addition_for_discussion_message_like_or_dislike
    assign_values_on_transaction_for_frontend
  end


  def ammend_discussion_message_karma
    new_amount = @permitted_attributes['amount']
    #if user liked what was liked this like is cancelled
    #so plainly it cancels all previous increments
    if new_amount == 1
      @discussion_message_karma.increment(:count, -1)
      #count_u not implemented todo implenet
      #@discussion_message_karma.increment(:count_u, -1)
    else
      @discussion_message_karma.increment(:count, 1)
      #not implemented
      #count_d is absoulute num
      #@discussion_message_karma.increment(:count_d, -1)
    end
  end


  def ammend_recieving_user_karma
    amount = @permitted_attributes['amount']
    @recieving_user_karma.set.when_this_users_discussion_message_like_or_dislike_cancelled(amount)

    record_recieving_user_karma_event(amount)
  end


  def record_recieving_user_karma_event(amount)
    ::Services::DayKarmaEvent::Factory.record_when_this_users_discussion_message_like_or_dislike_cancelled(
      user_id: @recieving_user_karma.user_id,
      amount: amount,
      discussion_message_id: @discussion_message_karma.discussion_message_id,
      source_text: @discussion_message_karma.discussion_message.content
    )
  end


  def cancel_current_user_previous_karma_addition_for_discussion_message_like_or_dislike

    @current_user_karma.updater.when_cancelled_previous_discussion_message_like_or_dislike
    @current_user_karma.save

    record_day_karma_event_when_discussion_message_like_or_dislike_cancelled(@current_user_karma)
  end


  def record_day_karma_event_when_discussion_message_like_or_dislike_cancelled(user_karma)
    ::Services::DayKarmaEvent::Factory.record_when_discussion_message_like_or_dislike_cancelled(
      user_id: user_karma.user_id,
      discussion_message_id: @discussion_message_karma.discussion_message_id,
      source_text: @discussion_message_karma.discussion_message.content
    )
  end


  def assign_values_on_transaction_for_frontend
    @user_change_amount = nil

    @user_change_amount = -UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED

    #client depends on amount to render whether like or disliked
    @discussion_message_karma_transaction.amount = 0
    #this is attr_accessor serves for frontend to render updated karma without fetching
    @discussion_message_karma_transaction.user_change_amount = @user_change_amount
  end


  def compose
    @discussion_message_karma.save!
    @discussion_message_karma_transaction.destroy!
    @recieving_user_karma.save!
    @current_user_karma.save!
  end


  def resolve_success
    publish(:ok, @discussion_message_karma_transaction)
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
