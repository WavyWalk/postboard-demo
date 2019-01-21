class ComposerFor::VotePollTransaction::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    find_and_set_option!
    find_or_new_transaction!
    assign_attributes
  end

  def permit_attributes
    @permitted_attributes = @params.require('vote_poll_transaction').permit('vote_poll_option_id')
  end

  def find_and_set_option!
    @vote_poll_option = VotePollOption.find(@permitted_attributes['vote_poll_option_id'])    
  end

  def find_or_new_transaction!
    if VotePollTransaction.where(user_id: @controller.current_user.id, post_vote_poll_id: @vote_poll_option.post_vote_poll_id).first
      
      fail_immediately(:transaction_exists)
    else
      
      @option_transaction = VotePollTransaction.new
    end
  end

  def assign_attributes
    @option_transaction.post_vote_poll_id = @vote_poll_option.post_vote_poll_id
    @option_transaction.vote_poll_option_id = @vote_poll_option.id
    @option_transaction.user_id = @controller.current_user.id

    @vote_poll_option.count ||= 0
    @vote_poll_option.count += 1
  end

  def compose
    @option_transaction.save!
    @vote_poll_option.save!
  end

  def resolve_success
    publish(:ok, {count: @vote_poll_option.count})
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @option_transaction)
    when :transaction_exists
      erronous_transaction = VotePollTransaction.new
      erronous_transaction.errors.add(:general, "voted_already")
      publish(:transaction_exists, erronous_transaction)
    else
      raise e
    end

  end

end
