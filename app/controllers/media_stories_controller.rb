class MediaStoriesController < ApplicationController

  def create
    permission_rules = build_permissions MediaStory
    authorize! permission_rules.create

    cmpsr = ComposerFor::MediaStories::Create.new(params, self)

    cmpsr.when(:ok) do |media_story|
      render json: AsJsonSerializer::MediaStories::Create.new(media_story).success
    end
 
    cmpsr.when(:validation_error) do |media_story|
      render json: AsJsonSerializer::MediaStories::Create.new(media_story).error
    end

    cmpsr.run
  end

  def update

    permission_rules = build_permissions MediaStory
    authorize! permission_rules.update(params['id'])

    cmpsr = ComposerFor::MediaStories::Update.new(params, self)

    cmpsr.when(:ok) do |media_story|
      render json: AsJsonSerializer::MediaStories::Update.new(media_story).success
    end
 
    cmpsr.when(:validation_error) do |media_story|
      render json: AsJsonSerializer::MediaStories::Update.new(media_story).error
    end

    cmpsr.run
    
  end

  def show
    media_story = MediaStory.find(params['id'])
    render json: AsJsonSerializer::MediaStories::Create.new(media_story).success 
  end

end
