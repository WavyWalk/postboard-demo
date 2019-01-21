class User < Model

  register

  attributes :id, :registered, :avatar, :s_avatar, :name

  has_one :user_credential, class_name: 'UserCredential', aliases: [:uc_s_name]

  has_one :user_karma, class_name: 'UserKarma'

  has_one :user_denormalized_stat, class_name: 'UserDenormalizedStat'

  has_many :subscribing_user_subscriptions, class_name: 'UserSubscription'

  has_many :discussion_message_karma_transactions, class_name: 'DiscussionMessageKarmaTransaction'

  has_many :post_karma_transactions, class_name: 'PostKarmaTransactions'

  has_many :user_roles, class_name: 'UserRole'

  has_one :usub_with_current_user, class_name: 'UserSubscription'

  has_many :notifications, class_name: 'Notification'

  route "create", post: "users"

  route 'login_via_pwd', post: 'sessions/login_via_pwd'
  route 'send_login_link', post: 'sessions/send_login_link'

  route "General_info", get: "users/general_info/:id"

  #route 'General_info_for_current_user', get: "users/general_info_for_current_user"

  route :ping_current_user, get: "users/ping_current_user"

  route :update_avatar, {post: "users/:id/avatars"}, {defaults: [:id]}

  def init(attributes)
    if self.s_avatar
      self.avatar = JSON.parse(s_avatar)
    end
  end

  def name
    if user_credential
      user_credential.name
    else
      @attributes[:name]
    end
  end

  def before_route_update_avatar(r)
    before_route_update(r)
  end

  def after_route_update_avatar(r)
    s_avatar = r.response.json
    if errors = s_avatar[:erorrs]
      self.errors[:avatar] = errors
    else
      self.avatar = s_avatar
    end
    r.promise.resolve(self)
  end

  def self.after_route_general_info(r)
    json = r.response.json
    result = {}
    result[:user] = User.parse(json[:user])
    result[:latest_user_posts] = Post.parse(json[:latest_user_posts])
    result[:top_post] = Post.parse(json[:top_post])
    result[:top_discussion_message] = DiscussionMessage.parse(json[:top_discussion_message])
    result[:latest_discussion_messages] = DiscussionMessage.parse(json[:latest_discussion_messages])
    result[:total_likes] = json[:total_likes]
    result[:total_dislikes] = json[:total_dislikes]
    result[:total_posts] = json[:total_posts]
    r.promise.resolve result
  end

  def first_subscribing_user_subscription_or_nil
    (_ = subscribing_user_subscriptions.empty?) ? nil : _.first
  end

  def after_route_ping_current_user(r)
    promise = Promise.new
    previous_karma = self.try(:user_karma).try(:count)
    self.after_route_update(r).then do |user|
      new_karma = user.try(:user_karma).try(:count)
      if new_karma && previous_karma
        CurrentUser.update_karma(new_karma - previous_karma)
      end
      promise.resolve(user)
    end
  end

  def before_route_login_via_pwd(r)
    self.before_route_update(r)
  end

  def after_route_login_via_pwd(r)
    self.after_route_update(r)
    #CurrentUser.set_user_and_login_status(self, true) unless self.has_errors?
  end

  def before_route_send_login_link(r)
    self.before_route_update(r)
  end

  def after_route_send_login_link(r)
    self.after_route_update(r)
  end

  # def self.after_route_general_info(r)
  #   self.after_route_show(r)
  # end

  def has_role?(role_name)
    if user_roles
      roles = user_roles.data.map do |role|
        role.name
      end

      roles.include?(role_name)
    end
  end

end
