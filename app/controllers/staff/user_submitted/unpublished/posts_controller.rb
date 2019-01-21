class Staff::UserSubmitted::Unpublished::PostsController < ApplicationController


  def set_published

    build_permissions Post

    authorize! @permission_rules.staff_user_submitted_unpublished_set_published

    cmpsr = ComposerFor::Staff::UserSubmitted::Unpublished::Posts::SetPublished.new(params: params, controller: self)

    cmpsr.when(:ok) do |post|

      render json: AsJsonSerializer::Staff::UserSubmitted::Post::SetPublished.new(post: post).success

    end

    cmpsr.run

  end



  def set_unpublished

    build_permissions Post

    authorize! @permission_rules.staff_user_submitted_unpublished_set_unpublished

    cmpsr = ComposerFor::Staff::UserSubmitted::Unpublished::Posts::SetUnPublished.new(params: params, controller: self)

    cmpsr.when(:ok) do |post|

      render json: AsJsonSerializer::Staff::UserSubmitted::Post::SetUnPublished.new(post: post).success

    end

    cmpsr.run

  end



end
