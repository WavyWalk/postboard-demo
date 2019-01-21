class PersonalityTests::TestQuestionsController < ApplicationController

  def create
    permissions = Permissions::TestQuestionRules.new(TestQuestion, self)
    authorize! permissions.create(post_test_id: params['post_test_id'])

    cmpsr = ComposerFor::PersonalityTests::TestQuestions::Create.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: AsJsonSerializer::PersonalityTests::TestQuestions::Create.new(test_question).success
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: AsJsonSerializer::PersonalityTests::TestQuestions::Create.new(test_question).error
    end

    cmpsr.run
  end

  def destroy
    permissions = Permissions::TestQuestionRules.new(TestQuestion, self)
    authorize! permissions.personality_test_destroy(post_test_id: params['personality_test_id'], id: params['id'])

    cmpsr = ComposerFor::PersonalityTests::TestQuestions::Destroy.new(params, self)

    cmpsr.when(:ok) do |test_question|
      render json: AsJsonSerializer::PersonalityTests::TestQuestions::Destroy.new(test_question).success
    end

    cmpsr.when(:validation_error) do |test_question|
      render json: AsJsonSerializer::PersonalityTests::TestQuestions::Destroy.new(test_question).error
    end

    cmpsr.run
  end

end
