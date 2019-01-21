class Users::PostsController < ApplicationController


  def index

    user_id = params[:id]

    build_permissions Post
 
    authorize! @permission_rules.users_index(user_id)

    @pagination_settings = pagination_service.extract_pagintaion_settings(params)

    posts = Post.qo_service.for_users_post_index(@pagination_settings, current_user.id)

    @pagination = pagination_service.extract_pagination_hash(posts)

    render json: AsJsonSerializer::Users::Posts::Index.new(posts: posts).success << @pagination

  end  


end