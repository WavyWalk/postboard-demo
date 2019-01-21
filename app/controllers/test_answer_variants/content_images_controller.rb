class TestAnswerVariants::ContentImagesController < ApplicationController

  def update
    permissions = build_permissions(TestAnswerVariant)
    authorize!(
      permissions.update_content_image(
        test_answer_variant_id: params['test_answer_variant_id']
      )
    )

    cmpsr = ComposerFor::TestAnswerVariants::ContentImages::Update.new(params, self)

    cmpsr.when(:ok) do |test_answer_variant|
      render json: test_answer_variant.content.as_json
    end

    cmpsr.when(:validation_error) do |test_answer_variant|
      render json: test_answer_variant.content.as_json(methods: [:errors])
    end

    cmpsr.when(:variant_does_not_exist) do |test_answer_variant_image|
      render json: test_answer_variant_image.as_json(methods: [:errors])
    end

    cmpsr.run
  end

  def destroy
    permissions = build_permissions(TestAnswerVariant)
    authorize!(
      permissions.update_content_image(
        test_answer_variant_id: params['test_answer_variant_id']
      )
    )

    tv = TestAnswerVariant.find(params['test_answer_variant_id'])
    tv.content_id  = nil
    tv.content_type = nil
    tv.save

    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_answer_variant_content_destroyed(tv)

    render json: PostImage.find(params[:id]).as_json
  end

end
