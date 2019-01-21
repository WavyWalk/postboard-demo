class Services::DayKarmaEvent::Factory

  def self.record_when_this_users_post_liked_or_disliked(
    user_id:, amount:, post_id:, source_text:
  )

    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_post(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED,
      day_karma_stat,
      post_id,
      source_text
    )

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)

  end


  def self.record_when_post_liked_or_disliked(
    user_id:, amount:, post_id:, source_text:
  )
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)


    day_karma_event = find_or_create_day_karma_event_when_source_is_post(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_POST_LIKED_OR_DISLIKED,
      day_karma_stat,
      post_id,
      source_text
    )

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)
  end


  def self.record_when_fresh_post_liked_or_disliked(user_id:, amount:, post_id:, source_text:)
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_post(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_FRESH_POST_LIKED_OR_DISLIKED,
      day_karma_stat,
      post_id,
      source_text
    )

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)
  end


  def self.when_this_users_post_like_or_dislike_cancelled(user_id:, amount:, post_id:, source_text:)
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    case amount
    when 1
      day_karma_event = find_or_create_day_karma_event_when_source_is_post(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_POST_LIKE_CANCELLED,
        day_karma_stat,
        post_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, -::UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED)

    when -1
      day_karma_event = find_or_create_day_karma_event_when_source_is_post(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_POST_DISLIKE_CANCELLED,
        day_karma_stat,
        post_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, ::UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED)

    end
  end


  def self.when_this_users_post_like_or_dislike_reversed(user_id:, amount:, post_id:, source_text:)
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    case amount
    when 1
      #creates to separate events
      day_karma_event = find_or_create_day_karma_event_when_source_is_post(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_POST_DISLIKE_CANCELLED,
        day_karma_stat,
        post_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, ::UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED)

      self.record_when_this_users_post_liked_or_disliked(
        user_id: user_id, amount: (1 * UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED),
        post_id: post_id, source_text: source_text
      )
    when -1
      day_karma_event = find_or_create_day_karma_event_when_source_is_post(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_POST_LIKE_CANCELLED,
        day_karma_stat,
        post_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, -::UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED)

      self.record_when_this_users_post_liked_or_disliked(
        user_id: user_id, amount: (-1 * ::UserKarma::Constants::WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED),
        post_id: post_id, source_text: source_text
      )
    end
  end


  def self.when_post_like_or_dislike_cancelled(user_id:, post_id:, source_text:, post_is_hot:)
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_post(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_POST_LIKE_OR_DISLIKE_CANCELLED,
      day_karma_stat,
      post_id,
      source_text
    )

    amount = nil
    if post_is_hot
      amount = -::UserKarma::Constants::WHEN_POST_LIKED_OR_DISLIKED
    else
      amount = -::UserKarma::Constants::WHEN_FRESH_POST_LIKED_OR_DISLIKED
    end

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)
  end


  def self.record_when_user_created_post(user_id:, post_id:, source_text:)
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_post(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_USER_CREATED_POST,
      day_karma_stat,
      post_id,
      source_text
    )

    amount = ::UserKarma::Constants::WHEN_USER_CREATED_POST

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)
  end


  def self.find_or_create_day_karma_stat_for_today(user_id)
    ::DayKarmaStat.where(user_id: user_id, created_at: Date.today).first_or_create do |day_karma_stat|
      day_karma_stat.user_id = user_id
      day_karma_stat.created_at = Date.today
    end
  end

  def self.find_or_create_day_karma_event_when_source_is_post(user_id, event_type, day_karma_stat, post_id, source_text)
    ::DayKarmaEvent
      .where(
        user_id: user_id,
        day_karma_stat_id: day_karma_stat.id,
        event_type: event_type,
        source_id: post_id
      )
      .first_or_create do |day_karma_event|
        day_karma_event.day_karma_stat_id = day_karma_stat.id
        day_karma_event.user_id = user_id
        day_karma_event.source_type = 'Post'
        day_karma_event.source_id = post_id
        day_karma_event.event_type = event_type
        day_karma_event.source_text = source_text
      end
  end


  def self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)

    if amount > 0
      day_karma_stat.up_count += amount
      day_karma_event.up_count += amount
    else
      day_karma_stat.down_count += amount
      day_karma_event.down_count += amount
    end

    day_karma_stat.save
    day_karma_event.save

  end

  def self.record_when_this_users_discussion_message_liked_or_disliked(
    user_id:,
    amount:,
    discussion_message_id:,
    source_text:
  )

    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED,
      day_karma_stat,
      discussion_message_id,
      source_text
    )

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)

  end

  def self.record_when_discussion_message_liked_or_disliked(
    user_id:,
    amount:,
    discussion_message_id:,
    source_text:
  )

    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED,
      day_karma_stat,
      discussion_message_id,
      source_text
    )

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)

  end


  def self.record_when_discussion_message_like_or_dislike_cancelled(
    user_id:, discussion_message_id:, source_text:
  )
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
      user_id,
      Services::DayKarmaEvent::EventTypes::WHEN_DISCUSSION_MESSAGE_LIKE_OR_DISLIKE_CANCELLED,
      day_karma_stat,
      discussion_message_id,
      source_text
    )

    amount = -::UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED

    self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, amount)

  end


  def self.record_when_this_users_discussion_message_like_or_dislike_cancelled(
    user_id:, amount:, discussion_message_id:, source_text:
  )
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    case amount
    when 1
      day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKE_CANCELLED,
        day_karma_stat,
        discussion_message_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, -::UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED)

    when -1
      day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_DISCUSSION_MESSAGE_DISLIKE_CANCELLED,
        day_karma_stat,
        discussion_message_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, ::UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED)

    end
  end


  def self.when_this_users_discussion_message_like_or_dislike_reversed(
    user_id:, amount:, discussion_message_id:, source_text:
  )
    day_karma_stat = self.find_or_create_day_karma_stat_for_today(user_id)

    case amount
    when 1
      #creates to separate events
      day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_DISCUSSION_MESSAGE_DISLIKE_CANCELLED,
        day_karma_stat,
        discussion_message_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, ::UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED)

      self.record_when_this_users_discussion_message_liked_or_disliked(
        user_id: user_id, amount: (1 * UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED),
        discussion_message_id: discussion_message_id, source_text: source_text
      )
    when -1
      day_karma_event = find_or_create_day_karma_event_when_source_is_discussion_message(
        user_id,
        Services::DayKarmaEvent::EventTypes::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKE_CANCELLED,
        day_karma_stat,
        discussion_message_id,
        source_text
      )
      self.increment_up_or_down_count_on(day_karma_stat, day_karma_event, -::UserKarma::Constants::WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED)

      self.record_when_this_users_discussion_message_liked_or_disliked(
        user_id: user_id, amount: (-1 * ::UserKarma::Constants::WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED),
        discussion_message_id: discussion_message_id, source_text: source_text
      )
    end
  end



  def self.find_or_create_day_karma_event_when_source_is_discussion_message(
    user_id, event_type, day_karma_stat, discussion_message_id, source_text
  )

    ::DayKarmaEvent
      .where(
        user_id: user_id,
        day_karma_stat_id: day_karma_stat.id,
        event_type: event_type,
        source_id: discussion_message_id
      )
      .first_or_create do |day_karma_event|
        day_karma_event.day_karma_stat_id = day_karma_stat.id
        day_karma_event.user_id = user_id
        day_karma_event.source_type = 'DiscussionMessage'
        day_karma_event.source_id = discussion_message_id
        day_karma_event.event_type = event_type
        day_karma_event.source_text = source_text
      end

  end


end
