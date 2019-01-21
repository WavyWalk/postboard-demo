class TestQuestions::OnAnsweredMContentImagesController < ApplicationController

  def update
    permissions = build_permissions(TestQuestion)
    authorize!(
      permissions.update_content_image(
        test_question_id: params['test_question_id']
      )
    )

    cmpsr = ComposerFor::TestQuestions::OnAnsweredMContentImages::Update.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: test_question.on_answered_m_content.as_json
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: test_question.on_answered_m_content.as_json(methods: [:errors])
    end

    cmpsr.when(:question_does_not_exist) do |test_question_image|
      render json: on_answered_m_content.as_json(methods: [:errors])
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
    tq.on_answered_m_content_id  = nil
    tq.on_answered_m_content_type = nil
    tq.save

    ::Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_question_on_answered_m_content_destroyed(tq)

    render json: PostImage.find(params[:id]).as_json
    
  end

end
