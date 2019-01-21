class DayKarmaEvent < Model
  register

  attributes :id, :day_karma_stat_id, :up_count, :down_count, :source_id, :source_type, :event_type, :user_id, :source_text, :created_at, :updated_at

  has_one :source, polymorphic_type: :source_type

  EVENT_TYPES = {
    1 => "someone voted your post",#'WHEN_THIS_USERS_POST_LIKED_OR_DISLIKED',
    2 => "someone canceled like to your post",#'WHEN_THIS_USERS_POST_LIKE_CANCELLED',
    3 => "someone canceled dislike to your post",#'WHEN_THIS_USERS_POST_DISLIKE_CANCELLED',
    4 => "post vote",#'WHEN_POST_LIKED_OR_DISLIKED',
    5 => "fresh post vote",#'WHEN_FRESH_POST_LIKED_OR_DISLIKED',
    6 => "cancelled post vote",#'WHEN_POST_LIKE_OR_DISLIKE_CANCELLED',
    7 => "created a post",#'WHEN_USER_CREATED_POST',
    8 => "someone voted your comment",#'WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED',
    9 => "someone cancelled like on your comment",#'WHEN_THIS_USERS_DISCUSSION_MESSAGE_LIKE_CANCELLED',
    10 => "someone cancelled dislike on your comment",#'WHEN_THIS_USERS_DISCUSSION_MESSAGE_DISLIKE_CANCELLED',
    11 => "comment vote",#'WHEN_DISCUSSION_MESSAGE_LIKED_OR_DISLIKED',
    12 => "comment vote canceled"#'WHEN_DISCUSSION_MESSAGE_LIKE_OR_DISLIKE_CANCELLED'
  }


end
