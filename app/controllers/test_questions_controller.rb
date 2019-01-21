class TestQuestionsController < ApplicationController

  def create

    permissions = build_permissions(TestQuestion)
    authorize!(permissions.create(post_test_id: params['post_test_id']))

    cmpsr = ComposerFor::TestQuestions::Create.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: AsJsonSerializer::TestQuestions::Create.new(test_question).success
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: AsJsonSerializer::TestQuestions::Create.new(test_question).error
    end

    cmpsr.run

  end


  def update

    permissions = build_permissions(TestQuestion)
    authorize!(permissions.create(post_test_id: params['post_test_id']))

    cmpsr = ComposerFor::TestQuestions::Update.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: test_question.as_json()
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: test_question.as_json(methods: [:errors])
    end

    cmpsr.when(:question_does_not_exist) do |test_question|
      render json: test_question.as_json(methods: [:errors])
    end

    cmpsr.run

  end


  def destroy
    permissions = build_permissions(TestQuestion)
    authorize!(permissions.destroy(test_question_id: params['id']))

    cmpsr = ComposerFor::TestQuestions::Destroy.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: test_question.as_json()
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: test_question.as_json(methods: [:errors])
    end

    cmpsr.when(:question_does_not_exist) do |test_question|
      render json: test_question.as_json(methods: [:errors])
    end

    cmpsr.run
  end


end
