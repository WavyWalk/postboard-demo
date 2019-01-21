class Staff::UserSubmitted::PostsController < ApplicationController



  def edit

    build_permissions Post

    authorize! @permission_rules.staff_edit

    post = Post.qo_service.staff_edit_get(by_id: params[:id])  

    render json: AsJsonSerializer::Staff::UserSubmitted::Posts::Edit.new(post: post, controller: self).success

  end




  def update

    build_permissions Post

    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::UserSubmitted::Posts::Update.new(params: params, controller: self)

    cmpsr.when(:ok) do |post|
      render json: AsJsonSerializer::Staff::UserSubmitted::Posts::Edit.new(post: post, controller: self).success
    end

    cmpsr.when(:validation_error) do |post, post_nodes, post_thumbs|
      render json: AsJsonSerializer::Staff::UserSubmitted::Posts::Edit.new(post: post, post_nodes: post_nodes, post_thumbs: post_thumbs, controller: self).error
    end
    cmpsr.run

  end


end
