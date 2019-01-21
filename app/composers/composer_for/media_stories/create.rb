class ComposerFor::MediaStories::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    build_and_set_media_story
    run_validations
  end
 
  def permit_attributes
    @permitted_attributes = @params.require(
      'media_story'
    ).permit(
      'title',
      'media_story_nodes' => [
        'media_type',
        'media_id',
        'annotation',
        {
          'media' => ['id', 'link']
        } 
      ]
    )
  end

  def build_and_set_media_story
    media_story_factory = MediaStory
                            .factory.new
                            .initialize_for_create(@permitted_attributes)
                            .add_user_id( @controller.current_user.id )
                            .add_media_story_nodes( 
                              build_media_story_nodes(@permitted_attributes['media_story_nodes']) 
                            )
  
    @media_story = media_story_factory.get_result
  end

  def build_media_story_nodes(attributes)
    attributes ||= []
    media_story_nodes = []

    attributes.each do |individual_media_story_node_attributes|
      media_story_node_factory = MediaStoryNode.factory.new
        .initialize_for_media_story_create(individual_media_story_node_attributes)

      media_story_nodes << media_story_node_factory.get_result        
    end

    return media_story_nodes
  end

  def run_validations
    @media_story.validation_service.set_scenarios(:create).validate
    @media_story.media_story_nodes.each do |media_story_node|
      media_story_node.validation_service.set_scenarios(:media_story_create).validate
    end
  end

  def compose
    @media_story.save!
    set_orphaned_resources_unorphaned
  end

  def set_orphaned_resources_unorphaned
    images = []
    @media_story.media_story_nodes.each do |media_story_node|
      case media_story_node.media_type
      when 'PostImage'
        images << media_story_node.media
      end
    end

    images.each do |image|
      image.orphaned = false
      image.save!
    end
  end

  def resolve_success
    publish(:ok, @media_story)
  end

  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @media_story)
    else
      raise e
    end
  end

end
