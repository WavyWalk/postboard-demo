class PostTestGradationsController < ApplicationController

  def create
    permissions = build_permissions(PostTestGradation)
    authorize!(permissions.create(post_test_id: params['post_test_id']))

    cmpsr = ComposerFor::PostTestGradations::Create.new(params, self)

    cmpsr.when(:ok) do |post_test_gradation|
      render json: post_test_gradation.as_json(
        include: [content: {methods: [:post_size_url]}]
      )
    end

    cmpsr.when(:validation_error) do |post_test_gradation|
      render json: post_test_gradation.as_json(
        methods: [:errors],
        include: [{content: {methods: [:errors, :post_size_url]}}]
      )
    end

    cmpsr.run

  end

  def update

    permissions = build_permissions(PostTestGradation)
    authorize!(permissions.create(post_test_id: params['post_test_id']))

    cmpsr = ComposerFor::PostTestGradations::Create.new(params, self)

    cmpsr.when(:ok) do |post_test_gradation|
      render json: post_test_gradation.as_json(
        
      )
    end

    cmpsr.when(:validation_error) do |post_test_gradation|
      render json: post_test_gradation.as_json(
        methods: [:errors]
      )
    end

    cmpsr.run
    

  end


  def destroy
    permissions = build_permissions(PostTestGradation)
    authorize!(permissions.destroy(id: params['id']))

    gradation = PostTestGradation.find(params[:id])
    gradation.destroy
    render json: gradation.as_json
  end

end
