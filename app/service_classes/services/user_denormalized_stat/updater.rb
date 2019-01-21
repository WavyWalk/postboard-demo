class Services::UserDenormalizedStat::Updater

  OWNER_MODEL = ::UserDenormalizedStat

  def self.create_denormalized_stat_for_users_that_do_not_have_it
    ::User.all.each do |user|
      subscriptions = user.subscribing_user_subscriptions
      subscriptions_count = subscriptions.length

      denormalized_stat = ::UserDenormalizedStat.new
      denormalized_stat.subscribers_count = subscriptions_count

      user.user_denormalized_stat = denormalized_stat

      user.save!

    end
  end


  def initialize(owner)
    @owner = owner
  end


  def increment_karma_count(amount)
    @owner.karma_count += amount
  end


  def increment_subscribers_count(amount)
    @owner.subscribers_count += amount
  end


  def increment_subscriptions_count(amount)
    @owner.subscriptions_count += amount
  end


  def increment_posts_count(amount)
    @owner.post_count += amount
  end

end