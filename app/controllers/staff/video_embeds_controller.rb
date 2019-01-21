class Staff::VideoEmbedsController < ApplicationController

  def create
    build_permissions Post
    authorize! @permission_rules.staff_user_submitted_update

    cmpsr = ComposerFor::Staff::VideoEmbeds::Create.new(params, self)

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

    cmpsr = ComposerFor::Staff::VideoEmbeds::Destroy.new(params, self)

    cmpsr.when(:ok) do |video_embed|
      render json: video_embed.as_json
    end

    cmpsr.when(:validation_error) do |video_embed|
      render json: video_embed.as_json(methods: [:errors])
    end

    cmpsr.run
  end

end
