class PersonalityTests::TestAnswerVariantsController < ApplicationController

  def create
    permissions = Permissions::TestAnswerVariantRules.new(TestAnswerVariant, self)
    authorize! permissions.personality_test_create(params)

    cmpsr = ComposerFor::PersonalityTests::TestAnswerVariants::Create.new(params, self)

    cmpsr.when(:ok) do |test_answer_variant|
      
      render json: AsJsonSerializer::PersonalityTests::TestAnswerVariants::Create.new(test_answer_variant).success
    end    

    cmpsr.when(:validation_error) do |test_answer_variant|
      
      render json: AsJsonSerializer::PersonalityTests::TestAnswerVariants::Create.new(test_answer_variant).error 
    end
  
    cmpsr.run
  end

  def destroy
    permissions = Permissions::TestAnswerVariantRules.new(TestAnswerVariant, self)
    authorize! permissions.personality_test_destroy(id: params['id'])

    cmpsr = ComposerFor::PersonalityTests::TestAnswerVariants::Destroy.new(params, self)

    cmpsr.when(:ok) do |test_answer_variant|
      render json: AsJsonSerializer::PersonalityTests::TestAnswerVariants::Destroy.new(test_answer_variant).success
    end    

    cmpsr.when(:validation_error) do |test_answer_variant|
      render json: AsJsonSerializer::PersonalityTests::TestAnswerVariants::Destroy.new(test_answer_variant).error 
    end
  
    cmpsr.run

  end

end
