class PostTestsController < ApplicationController

  def create

    permissions = build_permissions(PostTest)
    authorize!(permissions)

    cmpsr = ComposerFor::PostTests::Create.new(params, self)

    cmpsr.when(:ok) do |post_test|
      render json: AsJsonSerializer::PostTests::Create.new(post_test).success
    end

    cmpsr.when(:validation_error) do |post_test|
      render json: AsJsonSerializer::PostTests::Create.new(post_test).error
    end

    cmpsr.run
  end


  def update

    permissions = build_permissions(PostTest)
    authorize!(permissions)

    cmpsr = ComposerFor::PostTests::Update.new(params, self)

    cmpsr.when(:ok) do |post_test|
      render json: post_test.as_json
    end

    cmpsr.when(:validation_error) do |post_test|
      render json: post_test.as_json(methods: [:errors])
    end

    cmpsr.run

  end


  def show

    post_test_id = params[:id]

    post_test = PostTest.find(post_test_id)

    render json: AsJsonSerializer::PostTests::Create
    .new(post_test)
    .success

  end

end
