class ComposerFor::MediaStories::MediaStoryNodes::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_media_story_node
  end

  def find_and_set_media_story_node
    @media_story_node = MediaStoryNode.where(id: @params['id']).first
    unless @media_story_node
      fail_immediately(:record_not_found)
    end
  end

  def compose
    @media_story_node.destroy!    
  end

  def resolve_success
    publish(:ok, @media_story_node)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid 
      publish(:validation_error, @media_story_node)
    when :record_not_found
      publish(:record_not_found, media_story_with_error(:general, "not found"))
    else
      raise e
    end

  end

  def media_story_with_error(type, msg)
    media_story_node = MediaStoryNode.new
    media_story_node.errors[type] = msg
    media_story_node
  end

end
