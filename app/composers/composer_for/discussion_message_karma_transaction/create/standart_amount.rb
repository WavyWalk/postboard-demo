class ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmount < ComposerFor::Base

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
  end

  def ammend_discussion_message_karma

    @discussion_message_karma.increment(:count, @discussion_message_karma_transaction.amount)

    #count u count d not implemented TODO: implement
    # if @discussion_message_karma_transaction.amount > 0
    #   @discussion_message_karma.count_u = @discussion_message_karma.count_u.to_i + @discussion_message_karma_transaction.amount
    # else
    #   @discussion_message_karma.count_d = @discussion_message_karma.count_d.to_i + @discussion_message_karma_transaction.amount.abs
    # end

  end


  def ammend_recieving_user_karma

    @recieving_user_karma.set.when_this_users_discussion_message_liked_or_disliked(
      @discussion_message_karma_transaction.amount
    )

    record_day_karma_event_when_this_users_discussion_message_liked_or_disliked

  end


  def record_day_karma_event_when_this_users_discussion_message_liked_or_disliked
    ::Services::DayKarmaEvent::Factory.record_when_this_users_discussion_message_liked_or_disliked(
      user_id: @recieving_user_karma.user_id,
      #amount is 1 || -1 it's this constant acts as qoeficient, inheriting the sign of amount (- \ +)
      amount: (@discussion_message_karma_transaction.amount * UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED),
      discussion_message_id: @discussion_message_karma.discussion_message_id,
      source_text: @discussion_message_karma.discussion_message.content
    )
  end


  def compose
    @discussion_message_karma_transaction.save!
    @discussion_message_karma.save!
    @recieving_user_karma.save!

    add_karma_to_current_user_when_discussion_message_liked_or_disliked!
  end


  def add_karma_to_current_user_when_discussion_message_liked_or_disliked!

    @current_user_karma.updater.add_karma_when_discussion_message_liked_or_disliked
    #frontend will use this value to increment there. this is attr_accessor
    @discussion_message_karma_transaction.user_change_amount = UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED

    ::Services::DayKarmaEvent::Factory.record_when_discussion_message_liked_or_disliked(
      user_id: @controller.current_user.id,
      amount: UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED,
      discussion_message_id: @discussion_message_karma.discussion_message_id,
      source_text: @discussion_message_karma.discussion_message.content
    )

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
