class TestQuestions::ContentImagesController < ApplicationController

  def update

    permissions = build_permissions(TestQuestion)
    authorize!(
      permissions.update_content_image(
        test_question_id: params['test_question_id']
      )
    )

    cmpsr = ComposerFor::TestQuestions::ContentImages::Update.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: test_question.content.as_json
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: test_question.content.as_json(methods: [:errors])
    end

    cmpsr.when(:question_does_not_exist) do |test_question_image|
      render json: test_question_image.as_json(methods: [:errors])
    end

    cmpsr.run

  end

  def destroy
    permissions = build_permissions(TestQuestion)
    authorize!(
      permissions.update_content_image(
        test_question_id: params['test_question_id']
      )
    )
    
    tq = TestQuestion.find(params['test_question_id'])
    tq.content_id  = nil
    tq.content_type = nil
    tq.save

    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_question_content_image_destroyed(tq) 

    render json: PostImage.find(params[:id]).as_json
  end

end
