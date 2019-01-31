class PostsController < ApplicationController

  def create

    build_permissions Post

    authorize! @permission_rules

    cmpsr = ComposerFor::Posts::Create.new(Post.new, params, self)

    cmpsr.when(:ok) do |post|
      render json: AsJsonSerializer::Post::Create.new(post).success
    end

    cmpsr.when(:validation_error) do |post|
      render json: AsJsonSerializer::Post::Create.new(post).error
    end

    cmpsr.when(:post_node_from_client_is_empty_or_not_provided) do |post|
      render json: {errors: {general: ['at least one node should be provided']}}
    end

    cmpsr.run

  end


  def show

    post = Post.find(params[:id])

    post.qo_service.get_posts_with_nodes_and_karma_for_show(current_user.id)

    render json: AsJsonSerializer::Post::Show.new(post).success 

  end


  def index

    @pagination_settings = pagination_service.extract_pagintaion_settings(params)
    #some workaround for will paginate to not make 'count *' query
    #@pagination_settings[:total_entries] = 1

    #fresh_ids = Post.qo_service.fresh_ids

    #hot_post_karmas = Post.qo_service.hot_post_karmas_select_id(@pagination_settings)

    posts = hot_with_subscriptions_posts = Post.qo_service.hot_with_subscriptions(@pagination_settings, current_user.id)

    @pagination = pagination_service.extract_pagination_hash(hot_with_subscriptions_posts)
 
    fresh_posts = Post.qo_service.random_fresh_posts(current_user_id: current_user.id)
    
    #hot_ids = hot_post_karmas.pluck(:post_id)

    #posts = Post.qo_service.get_posts_by_id_for_index(fresh_ids + hot_ids, current_user_id: current_user.id)

    render plain: Oj.dump(AsJsonSerializer::Post::Index.new(posts: posts + fresh_posts).success << @pagination)

  # rescue Exception => e
  #   byebug
  end

end
