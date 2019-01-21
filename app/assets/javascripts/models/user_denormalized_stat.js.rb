class UserDenormalizedStat < Model
  register

  attributes :id, :subscribers_count, :comments_count, :karma_count, :posts_count, :subscriptions_count

end