class Staff::PostsController < ApplicationController




  def create

    build_permissions Post

    authorize! @permission_rules.staff_create

    cmpsr = ComposerFor::Staff::Posts::Create.new(Post.new, params, self)

    cmpsr.when(:ok) do |post|
      render json: AsJsonSerializer::Post::Create.new(post).success
    end

    cmpsr.when(:validation_error) do |post|
      render json: AsJsonSerializer::Post::Create.new(post).error
    end

    cmpsr.when(:post_node_from_client_is_empty_or_not_provided) do |post|
      render json: {post: {errors: {general: ['at least one node should be provided']}}}
    end

    cmpsr.run

  end




  def search

    build_permissions Post
    
    authorize! @permission_rules.staff_posts_search

    @pagination_settings = pagination_service.extract_pagintaion_settings(params)

    posts = ModelQuerier::PostSearchers::StaffIndex.new(params, @pagination_settings).get_relation

    @pagination = pagination_service.extract_pagination_hash(posts)

    render json: AsJsonSerializer::Staff::UserSubmitted::Post::Index.new(posts: posts).success << @pagination

  end


end
