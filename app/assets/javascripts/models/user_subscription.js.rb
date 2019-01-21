class UserSubscription < Model
 
  register

  attributes :id, :user_id, :to_user_id 

  has_one :to_user, class_name: 'User'

  route :create, {post: 'user_subscriptions'}

  route :destroy, {delete: 'user_subscriptions/:id'}, {defaults: [:id]}

  route :Index_for_user, {get: 'user_subscriptions/index_for_user/:id'}


  #RETURNS USER'S COLLECTION!!!!!!!
  def self.after_route_index_for_user(r)
    if r.response.ok?
      r.promise.resolve User.parse(r.response.json)
    end
  end

end