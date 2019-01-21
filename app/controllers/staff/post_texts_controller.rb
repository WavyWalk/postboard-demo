class Staff::PostTextsController < ApplicationController

  def update
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostTexts::Update.new(params, self)

    cmpsr.when(:ok) do |post_text|
      render json: post_text.as_json
    end

    cmpsr.when(:validation_error) do |post_text|
      render json: post_text.as_json(methods: [:errors])
    end

    cmpsr.run
  end

  def destroy
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostTexts::Destroy.new(params, self)

    cmpsr.when(:ok) do |post_text|
      render json: post_text.as_json
    end

    cmpsr.when(:validation_error) do |post_text|
      render json: post_text.as_json(methods: [:errors])
    end

    cmpsr.run
  end

  def create
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostTexts::Create.new(params, self)
    #WARNING RETURNS POSTNODE WITH POSTTEXT
    cmpsr.when(:ok) do |post_node|
      render json: post_node.as_json(
        include: [:node]
      )
    end

    cmpsr.when(:validation_error) do |post_node|
      render json: post_node.as_json(
        methods: [:errors],
        include: [{
          node: {methods: [:errors]}
        }]
      )
    end

    cmpsr.run
  end

end
