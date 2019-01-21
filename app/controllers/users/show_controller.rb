class Users::ShowController < ApplicationController


  def general_info
    #OLD
    # user_id = params[:id]

    # user = User.qo_service.users_show_general_info(user_id)

    # user_post_count = User.qo_service.post_count_for(user_id)

    # render json: AsJsonSerializer::Users::Show::GeneralInfo.new(user, user_post_count).success

    user = User.find(params[:id])

    latest_user_posts = Post.where(author_id: user.id).order(created_at: 'desc').limit(3).includes(:post_karma)

    latest_comments = DiscussionMessage.where(user_id: user.id).order(created_at: 'desc').limit(3)

    top_post = Post.joins('left join post_karmas on posts.id = post_karmas.post_id ').where('posts.author_id = ?', user).includes(:post_karma).order('post_karmas.count desc').limit(1).first

    top_comment = DiscussionMessage.where(user_id: user.id).order(created_at: 'desc').limit(1).first

    total_likes = PostKarmaTransaction.where(user_id: user.id, cancel_type: 'up').count()

    total_dislikes = PostKarmaTransaction.where(user_id: user.id, cancel_type: 'down').count()

    total_posts = Post.where(author_id: user.id).count

    render json: {
      user: user.as_json(include: [:uc_s_name, :user_karma]),
      latest_user_posts: latest_user_posts.as_json(include: [:post_karma]),
      latest_comments: latest_comments.as_json,
      top_post: top_post.as_json(include: [:post_karma]),
      top_comment: top_comment.as_json,
      total_likes: total_likes,
      total_dislikes: total_dislikes,
      total_posts: total_posts
    }

  end




  def general_info_for_current_user

    user = current_user

    latest_user_posts = Post.where(author_id: user.id).order(created_at: 'desc').limit(3).includes(:post_karma)

    latest_comments = DiscussionMessage.where(user_id: user.id).order(created_at: 'desc').limit(3)

    top_post = Post.joins('left join post_karmas on posts.id = post_karmas.post_id ').includes(:post_karma).order('post_karmas.count desc').limit(1).first

    top_comment = DiscussionMessage.where(user_id: user.id).order(created_at: 'desc').limit(1).first

    total_likes = PostKarmaTransaction.where(user_id: user.id, cancel_type: 'up').count()

    total_dislikes = PostKarmaTransaction.where(user_id: user.id, cancel_type: 'down').count()

    render json: {
      user: user.as_json(include: [:uc_s_name, :user_karma]),
      latest_user_posts: latest_user_posts.as_json(include: [:post_karma]),
      latest_comments: latest_comments.as_json,
      top_post: top_post.as_json(include: [:post_karma]),
      top_comment: top_comment.as_json,
      total_likes: total_likes,
      total_dislikes: total_dislikes
    }

  end




  def post_index

    user_id = params[:id]

    @pagination_settings = pagination_service.extract_pagintaion_settings(params)

    posts = Post.qo_service.users_show_index(user_id, @pagination_settings)

    @pagination = pagination_service.extract_pagination_hash(posts)

    render plain: Oj.dump(AsJsonSerializer::Post::Index.new(posts: posts).success << @pagination)

  end


end
