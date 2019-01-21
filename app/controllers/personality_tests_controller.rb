class PersonalityTestsController < ApplicationController

  # def new
  #   permissions = build_permissions(PostTest)
  #   authorize! permissions.personality_test_new

  #   cmpsr = ComposerFor::PersonalityTests::New.new(params, self)

  #   cmpsr.on(:ok) do |post_test|
  #     render json: post_test.as_json
  #   end

  #   cmpsr.on(:validation_error) do |post_test|
  #     render json: post_test.as_json(methods: [:errors])
  #   end
  # end

  def create
    permissions = Permissions::PersonalityTestRules.new(PostTest, self, {})
    authorize! permissions.create

    cmpsr = ComposerFor::PersonalityTests::Create.new(params, self)

    cmpsr.when(:ok) do |post_test|
      render json: AsJsonSerializer::PersonalityTests::Create.new(post_test).success
    end

    cmpsr.when(:validation_error) do |post_test|
      render json: AsJsonSerializer::PersonalityTests::Create.new(post_test).error 
    end

    cmpsr.run
  end

  def edit  
    permissions = Permissions::PersonalityTestRules.new(PostTest, self, {})
    authorize! permissions.edit(params[:id])

    personality_test = PostTest.find(params[:id])
    
    render json: AsJsonSerializer::PersonalityTests::Edit.new(personality_test).success
  end

  def show
    post_test = PostTest.find(params['id'])
    
    render json: AsJsonSerializer::PersonalityTests::Show.new(post_test).success
  end


end
