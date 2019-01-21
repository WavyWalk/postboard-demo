class Post < Model

  register

  attributes :id, :content, :nodes_order, :title, :s_nodes, :created_at, :udpated_at

  has_one :author, class_name: 'User', aliases: [:au_s_id]

  has_many :post_images, class_name: 'PostImage'

  has_many :post_nodes, class_name: 'PostNode', aliases: [:post_nodes_with_root]

  has_many :post_thumbs, class_name: 'PostThumb'

  has_one :post_karma, class_name: 'PostKarma'

  has_many :post_tags, class_name: 'PostTag'

  has_many :post_tag_links, class_name: 'PostTagLink'

  has_one :post_type, class_name: 'PostType'

  has_one :discussion, class_name: 'Discussion'




  route :create, post: "posts"

  route :Edit, get: 'posts/:id/edit'

  route :update, {put: 'posts/:id'}, {defaults: [:id]}

  route :Show, get: "posts/:id"

  route :Index, get: "posts"

  route :Index_for_user, {get: 'users/posts/index/:id'} 

  route :Index_for_user_show, {get: "users/show/post_index/:id"}

  route :set_published, put: "posts/set_published/:id"

  route :set_unpublished, put: "posts/set_unpublished/:id"

  route :perform_search, get: "posts/search"

  route :update_title, {post: "posts/:id/titles"}, {defaults: [:id]}
  # def validate_title
  #   if !title || title.to_s.length < 2
  #     add_error(:title, "too short")
  #   end
  # end
  def init(attributes) 
    if x = attributes[:s_nodes]
      self.s_nodes = PostNode.parse(JSON.parse(x))
    end
  end

  def sort_post_nodes_in_order_as_in_s_nodes
    current_post_nodes_data = self.post_nodes.data
    sorted_post_nodes_data = []

    s_nodes.each do |post_node|
      node_to_push = current_post_nodes_data.find do |_post_node|
        _post_node.id == post_node.id
      end
      sorted_post_nodes_data << node_to_push
    end

    self.post_nodes.data = sorted_post_nodes_data
  end

  def before_route_update_title(r)
    r.req_options = {payload: {post: {title: self.title}}}
  end

  def after_route_update_title(r)
    attrs = r.response.json
    returned_post = Post.parse(attrs)
    returned_post.validate
    r.promise.resolve(returned_post)
  end


  def self.after_route_index_for_user(r)
    self.after_route_index(r)
  end


  def self.after_route_index_for_user_show(r)
    self.after_route_index(r)
  end


  def before_route_perform_search(r)
    r.req_options = {payload: pure_attributes}
  end

  def after_route_perform_search(r)
    if r.response.ok?
      r.promise.resolve self.class.parse(r.response.json)
    end
  end

  def after_route_update(r)
    if r.response.ok?
      #self.update_attributes(r.response.json)
      to_yield = self.class.parse(r.response.json)
      to_yield.validate
      r.promise.resolve to_yield
    end
  end

  def nodes_sorted?
    @nodes_sorted
  end

  #TODO delete
  # def sort_nodes_in_order

  #   _post_nodes = ModelCollection.new
  #   self.post_nodes.each do |pn|
  #     _post_nodes.data[ self.nodes_order.index( pn.id) ] = pn
  #   end

  #   self.post_nodes = _post_nodes
  #   @nodes_sorted = true
  # end

  def set_whats_changed

    self.post_nodes.each do |post_node|
      if post_node.node.attributes[:_changed]
        post_node.attributes[:_changed] = true
      end

      if post_node.node.attributes[:_should_destroy]
        post_node.attributes[:_should_destroy] = true
      end
    end

    self.post_thumbs.each do |post_thumb|
      if post_thumb.node.attributes[:_changed]
        post_thumb.attributes[:_changed] = true
      end

      if post_thumb.node.attributes[:_should_destroy]
        post_thumb.attributes[:_should_destroy] = true
      end
    end

  end

  # def self.sort_post_nodes_to_right_order(post)
  #   _post_nodes = ModelCollection.new
  #   post.post_nodes.each do |pn|
  #     _post_nodes.data[ post.attributes[:nodes_order].index(pn.attributes[:post_node_id]) ] = pn
  #   end
  #   post.post_nodes = _post_nodes
  # end

end
