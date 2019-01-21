class Staff::PostTestsController < ApplicationController

  def create
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostTests::Create.new(params, self)

    cmpsr.when(:ok) do |post_node|
      render json: post_node.serialize_as_json_for_s_node
    end

    cmpsr.when(:validation_error) do |post_node|
      json_to_render = post_node.as_json
      json_to_render['node'] = AsJsonSerializer::PostTest::Create.new(post_node.node).error    
      
      render json: json_to_render
    end

    cmpsr.run
  end


  def destroy
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostTests::Destroy.new(params, self)

    cmpsr.when(:ok) do |post_test|
      render json: post_test.as_json
    end

    cmpsr.when(:validation_error) do |post_test|
      render json: post_test.as_json(methods: [:errors])
    end

    cmpsr.run
  end


end
