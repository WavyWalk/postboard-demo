class PostKarma < Model 

  register

  attributes :id, :count, :post_id

  has_one :post, class_name: 'Post'

  has_one :current_user_post_karma_transaction, class_name: 'PostKarmaTransaction', aliases: [:pkt_cu]

  has_many :post_karma_transactions, class_name: 'PostKarmaTransaction'

  route :update_count, post: 'post_karma/update_count'

  def before_route_update_count(r)
    before_route_update(r)
  end

  def current_user_pkt_or_new
    if current_user_post_karma_transaction 
      current_user_post_karma_transaction
    else
      self.current_user_post_karma_transaction = PostKarmaTransaction.new(post_karma_id: self.id, user_id: CurrentUser.instance.id)
      self.current_user_post_karma_transaction
    end
  end

  def after_route_update_count(r)
    after_route_update(r)
  end

end
