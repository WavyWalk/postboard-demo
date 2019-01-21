class TestAnswerVariantsController < ApplicationController

  def create

    permissions = build_permissions(TestAnswerVariant)
    authorize!(permissions.create(test_question_id: params['test_question_id']))

    cmpsr = ComposerFor::TestAnswerVariants::Create.new(params, self)

    cmpsr.when(:ok) do |answer_variant|
      render json: answer_variant.as_json(include: [:content])
    end

    cmpsr.when(:validation_error) do |answer_variant|
      render json: answer_variant.as_json(methods: [:errors], include: [content: {methods: [:errors]}])
    end

    cmpsr.run

  end



  def update

    permissions = build_permissions(TestAnswerVariant)
    authorize!(permissions.create(test_question_id: params['test_question_id']))

    cmpsr = ComposerFor::TestAnswerVariants::Update.new(params, self)

    cmpsr.when(:ok) do |answer_variant|
      render json: answer_variant.as_json()
    end

    cmpsr.when(:validation_error) do |answer_variant|
      render json: answer_variant.as_json(methods: [:errors])
    end

    cmpsr.run

  end
  

  def destroy
    permissions = build_permissions(TestAnswerVariant)
    authorize!(permissions.destroy(test_answer_variant_id: params['id']))

    cmpsr = ComposerFor::TestAnswerVariants::Destroy.new(params, self)

    cmpsr.when(:ok) do |test_answer_variant|
      render json: test_answer_variant.as_json()
    end

    cmpsr.when(:validation_error) do |test_answer_variant|
      render json: test_answer_variant.as_json(methods: [:errors])
    end

    cmpsr.when(:variant_does_not_exist) do |test_answer_variant|
      render json: test_answer_variant.as_json(methods: [:errors])
    end

    cmpsr.run
  end


end
