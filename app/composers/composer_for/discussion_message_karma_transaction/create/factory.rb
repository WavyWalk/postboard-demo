class ComposerFor::DiscussionMessageKarmaTransaction::Create::Factory

   include Services::PubSubBus::Publisher

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def create
    set_permitted_attributes
    find_or_initialize_discussion_message_karma_transaction
    set_discussion_message_karma!

    if liking_self?
      @should_return_self_as_composer = true
      @discussion_message_karma_transaction.errors.add(:general, "can't like your own post")
      @resolve_message = :liking_self
      return self
    end

    set_recieving_user_karma
    set_current_user_karma
    set_conditionals
    initialize_composer_depending_on_conditionals
  end

  def set_permitted_attributes
    @permitted_attributes = @params
      .require('discussion_message_karma_transaction')
      .permit('discussion_message_karma_id', 'amount')
  end


  def find_or_initialize_discussion_message_karma_transaction
    discussion_message_karma_transaction = ::DiscussionMessageKarmaTransaction.where(
      discussion_message_karma_id: @permitted_attributes['discussion_message_karma_id'],
      user_id: @controller.current_user.id
    ).first

    @discussion_message_karma_transaction = if discussion_message_karma_transaction
      discussion_message_karma_transaction
    else
      dmkt = ::DiscussionMessageKarmaTransaction.new
      dmkt.amount = @permitted_attributes['amount']
      dmkt.user_id = @controller.current_user.id
      dmkt.discussion_message_karma_id = @permitted_attributes['discussion_message_karma_id']
      dmkt
    end

  end


  def set_discussion_message_karma!
    @discussion_message_karma = ::DiscussionMessageKarma
      .where(id: @permitted_attributes['discussion_message_karma_id'])
      .first #TODO define not found rejection

    unless @discussion_message_karma
      @should_return_self_as_composer = true
      @resolve_message = :discussion_message_karma_not_found
    end
  end


  def liking_self?
    if @discussion_message_karma.discussion_message.user_id == @controller.current_user.id
      true
    end
  end


  def set_recieving_user_karma
    @recieving_user_karma = ModelQuerier::UserKarma
      .find_by_joined_discussion_message_id(
        @discussion_message_karma.discussion_message_id
      )
  end


  def set_current_user_karma
    @current_user_karma = @controller.current_user.user_karma
  end


  def set_conditionals
    @previous_transaction_exists = previous_transaction_exists?
    @is_standart_amount = is_standart_amount?
    @cancels_previous_transaction = cancels_previous?
    @reverses_transaction = reverses_transaction?
  end


  def previous_transaction_exists?
    !!@discussion_message_karma_transaction.id
  end


  def is_standart_amount?
     [1, -1].include?(@permitted_attributes['amount']) ? true : false
  end


  def cancels_previous?
    return false if !previous_transaction_exists?

    new_amount = @permitted_attributes['amount']
    old_amount = @discussion_message_karma_transaction.amount

    if old_amount == new_amount
      return true
    else
      return false
    end
  end


  def reverses_transaction?
    return false if !previous_transaction_exists?

    new_amount = @permitted_attributes['amount']
    old_amount = @discussion_message_karma_transaction.amount

    #reversed is considered if new amount is signed differently from previous
    if (new_amount < 0) != (old_amount < 0)
      return true
    end

  end


  def initialize_composer_depending_on_conditionals

    if @should_return_self_as_composer

      return self

    elsif @is_standart_amount && !@previous_transaction_exists

      return initialize_standart_amount_composer

    elsif @cancels_previous_transaction

      return initialize_standart_amount_composer_with_cancel_previous_transaction

    elsif @reverses_transaction

      return initialize_standart_amount_composer_with_reverse_previous_transaction

    else

      raise "#{self} of #{self.class.name} #initialize_composer_depending_on_conditionals condition reached unreacheable"

    end

  end

  def initialize_standart_amount_composer
    ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmount
    .new(
      discussion_message_karma_transaction: @discussion_message_karma_transaction,
      controller: @controller,
      discussion_message_karma: @discussion_message_karma,
      recieving_user_karma: @recieving_user_karma,
      permitted_attributes: @permitted_attributes,
      current_user_karma: @current_user_karma
    )
  end

  def initialize_standart_amount_composer_with_cancel_previous_transaction
    ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmountWithCancelPreviousTransaction
    .new(
      discussion_message_karma_transaction: @discussion_message_karma_transaction,
      controller: @controller,
      discussion_message_karma: @discussion_message_karma,
      recieving_user_karma: @recieving_user_karma,
      permitted_attributes: @permitted_attributes,
      current_user_karma: @current_user_karma
    )
  end

  def initialize_standart_amount_composer_with_reverse_previous_transaction
    ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmountWithReversePreviousTransaction
    .new(
      discussion_message_karma_transaction: @discussion_message_karma_transaction,
      controller: @controller,
      discussion_message_karma: @discussion_message_karma,
      recieving_user_karma: @recieving_user_karma,
      permitted_attributes: @permitted_attributes,
      current_user_karma: @current_user_karma
    )
  end


  def run
    if @resolve_message
      publish @resolve_message, @discussion_message_karma_transaction
    else
      raise "#{self} #{self.class.name} unexpected raise. Worth starting to trace bug from controller."
    end
  end



end
