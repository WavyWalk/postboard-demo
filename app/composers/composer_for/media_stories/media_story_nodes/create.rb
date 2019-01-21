class ComposerFor::MediaStories::MediaStoryNodes::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    find_and_set_media_story
    set_media_story_node_and_assign_attibutes
    validate
  end

  def permit_attributes
    @permitted_attributes = @params.require(
      'media_story_node'
    ).permit(
      'media_type',
      'media_id',
      'annotation',
      {
        'media' => ['id', 'link']
      }
    )
  end

  def find_and_set_media_story
    @media_story = MediaStory.where(id: @params['media_story_id']).first
    unless @media_story
      fail_immediately(:media_story_not_found)
    end        
  end

  def set_media_story_node_and_assign_attibutes
    factory = MediaStoryNode.factory.new
      .initialize_for_media_story_create(@permitted_attributes)
      .add_media_story_id(@media_story.id)
    @media_story_node = factory.get_result 
  end

  def validate
    @media_story_node.validation_service.set_scenarios(:media_story_create).validate
  end

  def compose
    @media_story_node.save!
  end

  def resolve_success
    publish(:ok, @media_story_node)  
  end

  def resolve_fail(e)
    
    case e
    when :media_story_not_found 
      raise e
      #publish(:media_story_not_found)
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @media_story_node)
    else
      raise e
    end

  end

end
