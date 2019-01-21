class ComposerFor::PostKarmaTransaction::Create::StandartAmount < ComposerFor::Base

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
  end


  def ammend_post_karma
    #amount here is always 1 || -1
    @post_karma.increment(:count, @post_karma_transaction.amount)

    if @post_karma_transaction.amount > 0
      @post_karma.count_u = @post_karma.count_u.to_i + @post_karma_transaction.amount
    else
      @post_karma.count_d = @post_karma.count_d.to_i + @post_karma_transaction.amount.abs
    end

    @post_karma = ::Services::PostKarma::ComposerHelpers.refine_hot_since(@post_karma)
  
  end


  def ammend_recieving_user_karma
    @recieving_user_karma.set.when_this_users_post_liked_or_disliked(@post_karma_transaction.amount)
      
    record_day_karma_event_when_this_users_post_liked_or_disliked
  end


  def record_day_karma_event_when_this_users_post_liked_or_disliked
    ::Services::DayKarmaEvent::Factory.record_when_this_users_post_liked_or_disliked(
      user_id: @recieving_user_karma.user_id,
      #amount is 1 || -1 it's this constant acts as qoeficient, inheriting the sign of amount (- \ +)
      amount: (@post_karma_transaction.amount * UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED),
      post_id: @post_karma.post_id,
      source_text: @post_karma.post.title
    )
  end


  def compose

    @post_karma_transaction.save!
    @post_karma.save!
    @recieving_user_karma.save!
    
    add_karma_to_current_user_when_post_liked_or_disliked!

  end


  def add_karma_to_current_user_when_post_liked_or_disliked! 
    if @post_karma.is_hot?
      @current_user_karma.updater.add_karma_when_post_liked_or_disliked
      #frontend will use this value to increment there. this is attr_accessor
      @post_karma_transaction.user_change_amount = UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED
      
      ::Services::DayKarmaEvent::Factory.record_when_post_liked_or_disliked(
        user_id: @controller.current_user.id,
        amount: UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED,
        post_id: @post_karma.post_id,
        source_text: @post_karma.post.title
      )
    else
      @current_user_karma.updater.add_karma_when_fresh_post_liked_or_disliked
      #frontend will use this value to increment there. this is attr_accessor
      @post_karma_transaction.user_change_amount = UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED
      
      ::Services::DayKarmaEvent::Factory.record_when_fresh_post_liked_or_disliked(
        user_id: @controller.current_user.id,
        amount: UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED,
        post_id: @post_karma.post_id,
        source_text: @post_karma.post.title
      )
    end

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
