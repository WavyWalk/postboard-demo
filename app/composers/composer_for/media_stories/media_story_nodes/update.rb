class ComposerFor::MediaStories::MediaStoryNodes::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    find_and_set_media_story_node
    set_media_changed_flag
    assign_attributes
    validate
  end


  def permit_attributes
    @permitted_attributes = @params.require('media_story_node')
      .permit(
        'media_type',
        'media_id',
        'annotation',
        {
          'media' => ['id', 'link']
        }
      )
  end

  def find_and_set_media_story_node
    @media_story_node = MediaStoryNode.where(id: @params['id']).first
    unless @media_story_node
      fail_immediately(:record_not_found)      
    end
  end
  
  def set_media_changed_flag
    media = @media_story_node.media
    if media.id == @permitted_attributes['media_id'] && @permitted_attributes['media_type'] == media.class.name.demodulize
      @media_changed_flag = false
    else
      @media_changed_flag = true
    end
  end


  def assign_attributes
    @media_story_node.annotation = @permitted_attributes['annotation']
    if @media_changed_flag
      @media_story_node.updater_service.replace_media_node(@permitted_attributes)
    end
  end

  def validate
    validator = @media_story_node.validation_service.set_scenarios(:update)
    if @media_changed_flag
      validator.set_scenarios(:media_node_changed)
    end
    validator.validate
  end

  def compose
    @media_story_node.save!
  end

  def resolve_success
    publish(:ok, @media_story_node)
  end

  def resolve_fail(e)
    
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @media_story_node)
    when :record_not_found
      publish(:record_not_found, @media_story_node)
    else
      raise e
    end

  end

end
