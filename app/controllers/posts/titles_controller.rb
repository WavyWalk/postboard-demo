class Posts::TitlesController < ApplicationController

  def update
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Posts::Titles::Update.new(params, self)

    cmpsr.when(:ok) do |post|
      render json: post.as_json(only: [:title, :id]) 
    end    

    cmpsr.when(:validation_error) do |post|
      render json: post.as_json(only: [:title, :id], methods: [:errors])
    end

    cmpsr.run

  end

end
