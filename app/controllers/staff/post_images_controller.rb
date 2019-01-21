class Staff::PostImagesController < ApplicationController

  def create
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostImages::Create.new(params, self)

    cmpsr.when(:ok) do |post_node|
      render json: post_node.as_json(
        include: [:node]
      )
    end

    cmpsr.when(:validation_error) do |post_node|
      render json: post_node.as_json(
        methods: [:errors],
        include: [
          {
            node: {
            methods: [
              :errors
              ]
            }
          }
        ]
      )
    end

    cmpsr.run
  end


  def destroy
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::PostImages::Destroy.new(params, self)

    cmpsr.when(:ok) do |post_image|
      render json: post_image.as_json
    end

    cmpsr.when(:validation_error) do |post_image|
      render json: post_image.as_json(methods: [:errors])
    end

    cmpsr.run
  end

end
