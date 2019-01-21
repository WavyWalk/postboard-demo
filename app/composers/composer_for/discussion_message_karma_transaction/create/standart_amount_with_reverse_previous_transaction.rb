class ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmountWithReversePreviousTransaction < ComposerFor::Base

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
    assign_new_attributes_to_discussion_message_karma_transaction
    ammend_discussion_message_karma
    ammend_recieving_user_karma
  end


  def assign_new_attributes_to_discussion_message_karma_transaction
    @discussion_message_karma_transaction.amount = @permitted_attributes['amount']
  end


  def ammend_discussion_message_karma
    amount = @permitted_attributes['amount']

    if amount == 1
      @discussion_message_karma.increment(:count, 2)
      #not implemented
      # @discussion_message_karma.increment(:count_u, 1)
      # @discussion_message_karma.increment(:count_d, -1)
    else
      @discussion_message_karma.increment(:count, -2)
      #not implemented
      # @discussion_message_karma.increment(:count_u, -1)
      # @discussion_message_karma.increment(:count_d, 1)
    end
  end


  def ammend_recieving_user_karma
    amount = @discussion_message_karma_transaction.amount
    @recieving_user_karma.set.when_this_users_discussion_message_like_or_dislike_reversed(amount)

    record_recieving_user_karma_event
  end


  def record_recieving_user_karma_event
    ::Services::DayKarmaEvent::Factory.when_this_users_discussion_message_like_or_dislike_reversed(
      user_id: @recieving_user_karma.user_id,
      amount: @discussion_message_karma_transaction.amount,
      discussion_message_id: @discussion_message_karma.discussion_message_id,
      source_text: @discussion_message_karma.discussion_message.content
    )
  end


  def compose
    @discussion_message_karma.save!
    @discussion_message_karma_transaction.save!
    @recieving_user_karma.save!
  end

  def resolve_success
    #frontend will take this value to render like or dislike
    @discussion_message_karma_transaction.amount = @permitted_attributes['amount']
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
