class ComposerFor::DiscussionMessageKarmaTransaction::Create::BuildComposer

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller
  end

  def create
    permit_and_set_permitted_attributes
    assign_attributes
    validate_model!

    set_discussion_message_karma_var!

    if liking_self?
      @model.errors.add(:general, "can't like your own post")
      @resolve_message = :liking_self
      return self
    end

    set_recieving_user_karma_var

    set_conditionals
    initialize_composer_depending_on_conditionals
  end

  def permit_and_set_permitted_attributes
    @permitted_attributes = @params.require(:discussion_message_karma_transaction).permit(:discussion_message_karma_id, :amount)
  end

  def assign_attributes
    @model.attributes = @permitted_attributes
    @model.user_id = @controller.current_user.id
    @model.cancel_type = define_cancel_type
  end

  def define_cancel_type
    if @model.amount == 1
      return 'up'
    elsif @model.amount == -1
      return 'down'
    else
      return nil
    end
  end

  def validate_model!
    
    ModelValidator::DiscussionMessageKarmaTransaction
      .new(@model)
      .set_scenarios(:create)
      .validate

    unless @model.valid? #valid is called to transfer to regular errors

      @should_return_self_as_composer = true
      @resolve_message = :validation_error

    end

  end

  def set_discussion_message_karma_var!
    @discussion_message_karma = DiscussionMessageKarma
      .where(id: @model.discussion_message_karma_id).first #TODO define not found rejection
    unless @discussion_message_karma
      @should_return_self_as_composer = true
      @resolve_message = :discussion_message_karma_not_found
    end
  end




  def liking_self?
    if @discussion_message_karma.discussion_message.user.id == @controller.current_user.id
      true
    end
  end  




  def set_recieving_user_karma_var
    
    @recieving_user_karma = ModelQuerier::UserKarma
                            .find_by_joined_discussion_message_id(@discussion_message_karma.discussion_message_id)

    unless @recieving_user_karma
      @should_return_self_as_composer = true
      @resolve_message = :recieving_user_karma_not_found
    end
  
  end

  def set_conditionals
    previous_transaction? #sets @previous_transaction
    is_standart_amount? #sets @is_standart_amount
  end

  def previous_transaction?
    @previous_transaction = DiscussionMessageKarmaTransaction
      .where(discussion_message_karma_id: @model.discussion_message_karma_id, user_id: @model.user_id).first
  end

  def is_standart_amount?
    @is_standart_amount = ( @model.amount == 1 || @model.amount == -1 ) ? true : false
  end

  def initialize_composer_depending_on_conditionals


    if @should_return_self_as_composer

      return self
    
    elsif @is_standart_amount && !@previous_transaction

      return initialize_standart_amount_composer

    elsif @is_standart_amount && @previous_transaction

      return initialize_standart_amount_with_previously_assigned_composer

    elsif !@is_standart_amount && !@previous_transaction

      return initialize_non_standart_amount_composer

    elsif !@is_standart_amount && @previous_transaction

      return initialize_non_standart_amount_with_previously_assigned_composer

    else

      raise "#{self} of #{self.class.name} #initialize_composer_depending_on_conditionals conditional reached unreacheable"

    end
  end

  def initialize_standart_amount_composer
    ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmount
                    .new(
                      model: @model, 
                      controller: @controller, 
                      discussion_message_karma: @discussion_message_karma,
                      recieving_user_karma: @recieving_user_karma
                    )
  end

  def initialize_standart_amount_with_previously_assigned_composer
    ComposerFor::DiscussionMessageKarmaTransaction::Create::StandartAmountWithPreviouslyAssigned
              .new(
                controller: @controller, 
                previous_transaction: @previous_transaction, 
                amount: @model.amount,
                discussion_message_karma: @discussion_message_karma,
                recieving_user_karma: @recieving_user_karma
              )
  end




  def initialize_non_standart_amount_composer
    ComposerFor::DiscussionMessageKarmaTransaction::Create::NonStandartAmount
          .new(
            @model, 
            @params, 
            @controller,
            discussion_message_karma: @discussion_message_karma,
            recieving_user_karma: @recieving_user_karma
          )
  end




  def initialize_non_standart_amount_with_previously_assigned_composer
    ComposerFor::DiscussionMessageKarmaTransaction::Create::NonStandartAmountWithPreviouslyAssigned
            .new(
              controller: @controller,
              previous_transaction: @previous_transaction,
              amount: @model.amount,
              discussion_message_karma: @discussion_message_karma,
              recieving_user_karma: @recieving_user_karma
            )
  end




  def run
    if @resolve_message
      publish @resolve_message, @model
    else
      raise "#{self} #{self.class.name} unexpected raise. Worth starting to trace bug from controller."
    end
  end

end
