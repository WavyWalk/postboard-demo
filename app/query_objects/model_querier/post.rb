class ModelQuerier::Post

  def initialize(qo = ::Post)
    @qo = qo
  end

  def get_relation
    @qo
  end

  def get_result
    @qo
  end

  #AGGREGATES

  def get_posts_with_nodes_and_karma_for_show(current_user_id)
    ::PostKarma.current_user_id_as_post_karma_transaction_owner_for_argless_includes = current_user_id
    @qo.post_nodes.includes(:node, post_karma: {includes: [:pkt_cu]})
  end


  def random_fresh_posts(current_user_id:)
    ::User.current_user_id_for_argless_includes = current_user_id
    ::PostKarma.current_user_id_as_post_karma_transaction_owner_for_argless_includes = current_user_id
    query = @qo
      .joins('left join post_karmas on posts.id = post_karmas.id')
      .where('posts.published = ? and posts.created_at > ? and post_karmas.hot_since is null', true, 3.days.ago)
      .includes(
        include_values_for_index
      )
      .order('random()')
      .limit(3)
  end

  def fresh_ids
    PostKarma.where('count < 50 and created_at > ?', 5.days.ago).order('random()').limit(3).pluck(:post_id)
  end

  def hot_post_karmas_select_id(pagination_options)
    hot_post_karmas = PostKarma.where('count > 49').select(:post_id).order('hot_since desc').paginate(pagination_options)
  end


  def get_posts_by_id_for_index(ids, current_user_id:)
    ::User.current_user_id_for_argless_includes = current_user_id
    query = @qo
      .where(id: ids)
      .where(published: true)
      .includes([:post_karma, {post_nodes: [:node]}, {au_s_id: [:uc_s_name, :usub_with_current_user]}, :post_tags])
      .order('posts.created_at desc')
    #User.current_user_id_for_argless_includes = nil #this as well required on serializarion so it will not get cleared
    query
  end


  def hot_with_subscriptions(pagination_options, current_user_id)
    #required for usub_with_current_user association query on posts author
    ::User.current_user_id_for_argless_includes = current_user_id
    ::PostKarma.current_user_id_as_post_karma_transaction_owner_for_argless_includes = current_user_id
    Post
      .joins('LEFT JOIN post_karmas ON posts.id = post_karmas.post_id LEFT JOIN user_subscriptions ON posts.author_id = user_subscriptions.to_user_id')
      .where('(post_karmas.hot_since is not null or user_subscriptions.user_id = ?) and posts.published = true', current_user_id)
      .includes(
        include_values_for_index
      )
      .order('posts.created_at desc')
      .paginate(pagination_options)
      .group('posts.id')
    #User.current_user_id_for_argless_includes = nil
  end


  def for_posts_index(pagination_options)
    query = @qo
      .includes(
        [:post_karma, post_nodes: [:node], au_s_id: [:uc_s_name]], :post_tags
      )
      .order('posts.created_at desc')
  end


  def users_show_index(user_id, pagination_options)
    query = @qo
      .includes([:post_karma, au_s_id: [:uc_s_name]], :post_tags)
      .where(author_id: user_id)
      .paginate(pagination_options)
      .order('posts.created_at desc')
  end



  def for_users_post_index(pagination_options, user_id)
    query = @qo
      .includes(
        include_values_for_index
      )
      .where('posts.author_id = ?', user_id)
      .paginate(pagination_options)
      .order('posts.created_at desc')
  end



  def get_staff_user_submitted_unpublished_index(pagination_options)
    @qo
      .includes(
        [:post_karma, post_nodes: [:node], au_s_id: [:uc_s_name]], :post_tags
      )
      .paginate(pagination_options)
      .order('posts.created_at desc')
  end


  def staff_edit_get(by_id:)
    @qo = @qo.where(id: by_id).includes(post_thumbs: [:node])
    full_includes
    get_relation.first
  end

  #END AGGREGATES




  #INDIVIDUAL

  def include_values_for_index
    [
      {post_karma: [:pkt_cu]}, 
      {author: [:usub_with_current_user, :user_denormalized_stat, :user_karma]}, 
      :post_tags, 
      :discussion
    ]
  end

  def standart_includes
    @qo = @qo.includes([:post_karma, post_nodes: [:node], au_s_id: [:uc_s_name]], :post_tags)#.select(:id, :author_id, :published_at, :title)
    self
  end

  def full_includes
    @qo = @qo.includes([:post_karma, post_nodes: [:node], author: [:uc_s_name]], :post_tags, :post_type)
  end

  def where_karma_count(more_than:)
    @qo = @qo.where('post_karmas.count > ?', more_than)
    self
  end


  def join_post_karma
    @qo = @qo.joins('INNER JOIN post_karmas ON post_karmas.post_id = posts.id')
    self
  end


  def join_post_tags
    @qo = @qo.joins(
      'INNER JOIN post_tag_links on post_tag_links.post_id = posts.id
       INNER JOIN post_tags on post_tags.id = post_tag_links.post_tag_id'
     )
    self
  end

  def where_post_tag_name(is_like:)
    @qo = @qo.where("post_tags.name like ?", "%#{is_like}%")
    self
  end

  def where_post_tags_in(post_tag_names_array)
    @qo = @qo.where('post_tags.name in (?)', post_tag_names_array)
    self
  end

  def join_author_user_credential #User
    @qo = @qo.joins(
      "INNER JOIN users ON users.id = posts.author_id
       INNER JOIN user_credentials ON user_credentials.user_id = users.id"
    )
    self
  end


  def where_title_like(title)
    @qo = @qo.where('posts.title like ?', "%#{title}%")
    self
  end

  def search_full_text(query)
    @qo = @qo.joins(:post_tsvs).merge(PostTsv.post_full_text_search(query))
    self
  end

  def where_author_name_like(name)
    @qo = @qo.where("user_credentials.name like ?", "%#{name}%")
    self
  end


  def is_published
    @qo = @qo.where("posts.published = ?", true)
    self
  end

  def is_unpublished
    @qo = @qo.where("posts.published is NULL or posts.published = ?", false)
    self
  end

  def order_by_created_at
    @qo = @qo.order('posts.created_at DESC')
  end

  def all_related_to_vote_poll_option(vote_poll_option)
    vote_poll_id = vote_poll_option.post_vote_poll_id
    @qo = @qo.joins(:post_nodes)
      .where(
        'post_nodes.node_id = ? and post_nodes.node_type = ?',
        vote_poll_id, 'PostVotePoll'
      )
    self
  end

  def all_related_to_post_vote_poll(post_vote_poll)
    vote_poll_id = post_vote_poll.id
    @qo = @qo.joins(:post_nodes)
      .where(
        'post_nodes.node_id = ? and post_nodes.node_type = ?',
        vote_poll_id, 'PostVotePoll'
      )
    self
  end

  def all_related_to_post_test(post_test)
    post_test_id = post_test.id

    @qo = @qo.joins(:post_nodes)
      .where(
        'post_nodes.node_id = ? and post_nodes.node_type = ?',
        post_test_id, 'PostTest'
      )
    self
  end

end
