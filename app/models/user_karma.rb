class UserKarma < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :user
  #END ASSOCIATIONS




  #TODO: remove occeurences; rename to updater
  def set
    @__Setter ||= self.class::Setter.new(self)
  end

  def updater
    @__updater  ||= self.class::Setter.new(self)
  end


  def amount_for_post_uv_dv

  end



  #TODO: move to own file rename as updater
  class Setter



    def initialize(owner)
      @owner = owner
    end


    def when_this_users_post_like_or_dislike_cancelled(amount)
      amount_to_increment = amount * -1 * UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end

    def when_this_users_discussion_message_like_or_dislike_cancelled(amount)
      amount_to_increment = amount * -1 * UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end


    def when_this_users_post_liked_or_disliked(amount)
      amount_to_increment = amount * UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end


    def when_this_users_post_like_or_dislike_reversed(amount)
      amount_to_increment  = amount * 2 * UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end


    def when_this_users_discussion_message_like_or_dislike_reversed(amount)
      amount_to_increment  = amount * 2 * UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end


    def when_this_users_discussion_message_liked_or_disliked(amount)
      amount_to_increment = amount * UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED
      @owner.increment(:count, amount_to_increment)
    end


    def add_karma_when_discussion_message_liked_or_disliked
      @owner.increment(:count, UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED)
    end


    def count(amount)
      @owner.count = @owner.count || 0
      @owner.count += amount
    end


    def add_for_post_creation
      @owner.count += UserKarma::Constants::WHEN_USER_CREATED_POST
    end

    def add_for_comment_creation
      @owner.count += UserKarma::Constants::FOR_COMMENT_CREATE
    end

    def add_karma_for_upw_or_dw_comment
      @owner.count += UserKarma::Constants::FOR_COMMENT_UPW_DW
    end

    def cancel_previous_karma_addition_for_comment_uw_dw
      @owner.count -= UserKarma::Constants::FOR_COMMENT_UPW_DW
    end

    def add_karma_when_post_liked_or_disliked
      @owner.count += UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED
    end

    def add_karma_when_fresh_post_liked_or_disliked
      @owner.count += UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED
    end

    def when_cancelled_previous_like_or_dislike(post_is_hot:)
      amount_to_increment = if post_is_hot
        -UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED
      else
        -UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED
      end
      @owner.count += amount_to_increment
    end

    def when_cancelled_previous_discussion_message_like_or_dislike
      amount_to_increment = -UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED
      @owner.count += amount_to_increment
    end

    def add_for_subscription_to_user
      @owner.count += UserKarma::Constants::SUBSCRIBED_TO_USER
    end

    def add_for_unsubscription_to_user
      @owner.count += UserKarma::Constants::UNSUBSCRIBED_FROM_USER
    end

    def add_when_user_subscribed_to_this_user
      @owner.count += UserKarma::Constants::SUBSCRIBED_TO_THIS_USER
    end

    def add_when_user_unsubscribed_from_this_user
      @owner.count += UserKarma::Constants::SUBSCRIBED_TO_THIS_USER
    end

  end

  class Constants

    POST_KARMA_MULTIPLIER = 5

    WHEN_USER_CREATED_POST = 100

    POST_UPVOTE_FOR_POST_AUTHOR = 20

    POST_DOWNVOTE_FOR_POST_AUTHOR = -20

    WHEN_POST_LIKED_OR_DISLIKED = 10

    WHEN_FRESH_POST_LIKED_OR_DISLIKED = 20

    FOR_COMMENT_CREATE = 50

    COMMENT_UPVOTE_FOR_AUTHOR = 5

    COMMENT_DOWNVOTE_FOR_AUTHOR = -5

    FOR_COMMENT_UPW_DW = 5

    SUBSCRIBED_TO_USER = 100

    UNSUBSCRIBED_FROM_USER = -100

    SUBSCRIBED_TO_THIS_USER = 500

    UNSUBSCRIBED_FROM_THIS_USER = -500

    WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED = 2

    WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED = 5

    #comes unsigned, depending on amount from client it will be multiplied by it setting the
    #sign for amount e/g/ -1 * this -50
    WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED = 50

  end






end
