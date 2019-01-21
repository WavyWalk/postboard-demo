class MediaStories::MediaStoryNodesController < ApplicationController

  def update
    
    permission_rules = build_permissions(MediaStoryNode)

    authorize!(permission_rules.update(
        media_story_id: params['media_story_id'],
        id: params['id']
      )
    )

    cmpsr = ComposerFor::MediaStories::MediaStoryNodes::Update.new(params, self)

    cmpsr.when(:ok) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Update.new(media_story_node).success
    end

    cmpsr.when(:validation_error) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Update.new(media_story_node).error
    end

    cmpsr.when(:record_not_found) do
      head 500
    end

    cmpsr.run

  end

  def create
    permission_rules = build_permissions(MediaStoryNode)

    authorize!(permission_rules.create(
      media_story_id: params['media_story_id'])
    )

    cmpsr = ComposerFor::MediaStories::MediaStoryNodes::Create.new(params, self)

    cmpsr.when(:ok) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Create.new(media_story_node).success
    end

    cmpsr.when(:validation_error) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Create.new(media_story_node).error
    end

    cmpsr.run
  end


  def destroy
    permission_rules = build_permissions(MediaStoryNode)

    authorize!(
      permission_rules.create(
        media_story_id: params['media_story_id']
      )
    )    

    cmpsr = ComposerFor::MediaStories::MediaStoryNodes::Destroy.new(params, self)

    cmpsr.when(:ok) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Destroy.new(media_story_node).success
    end

    cmpsr.when(:validation_error) do |media_story_node|
      render json: AsJsonSerializer::MediaStories::MediaStoryNodes::Destroy.new(media_story_node).error
    end

    cmpsr.run

  end

end
