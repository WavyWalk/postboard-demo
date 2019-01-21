class ComposerFor::MediaStories::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    set_media_story_id
    find_and_set_media_story
    assign_attributes
    validate_media_story
  end

  def permit_attributes
    @permitted_attributes = @params.require('media_story')
                                   .permit('title')
  end

  def set_media_story_id
    @media_story_id = @params['id']
  end

  def find_and_set_media_story
    @media_story = ::MediaStory.find(@media_story_id)
  end

  def assign_attributes
    @media_story.title = @permitted_attributes['title']
  end

  def validate_media_story
    @media_story.validation_service.set_scenarios(:update).validate
  end

  def compose
    @media_story.save!
  end

  def resolve_success
    publish(:ok, @media_story)
  end

  def resolve_fail(e)
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @media_story)
    else
      raise e
    end

  end

end
