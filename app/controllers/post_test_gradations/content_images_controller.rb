class PostTestGradations::ContentImagesController < ApplicationController

  def update
    permissions = build_permissions(PostTestGradation)
    authorize!(
      permissions.destroy(
        id: params['post_test_gradation_id']
      )
    )

    cmpsr = ComposerFor::PostTestGradations::ContentImages::Update.new(params, self)

    cmpsr.when(:ok) do |post_test_gradation|
      render json: post_test_gradation.content.as_json
    end

    cmpsr.when(:validation_error) do |post_test_gradation|
      render json: post_test_gradation.content.as_json(methods: [:errors])
    end

    cmpsr.when(:gradation_does_not_exist) do |post_test_gradation_image|
      render json: post_test_gradation_image.as_json(methods: [:errors])
    end

    cmpsr.run


    
  end

  def destroy
    permissions = build_permissions(PostTestGradation)
    authorize!(
      permissions.destroy(
        id: params['post_test_gradation_id']
      )
    )
    
    gr = PostTestGradation.find(params['post_test_gradation_id'])
    gr.content_id  = nil
    gr.content_type = nil
    gr.save
    render json: PostImage.find(params[:id]).as_json
  end

end
