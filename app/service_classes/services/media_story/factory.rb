class Services::MediaStory::Factory
  
  def initialize
    @model = ::MediaStory.new
  end 
  
  def initialize_for_create(attributes)
    @model.title = attributes['title']
    self
  end

  def add_user_id(user_id)
    @model.user_id = user_id
    self
  end

  def add_media_story_nodes(media_story_nodes)
    @model.media_story_nodes = media_story_nodes
    self
  end

  def get_result
    @model
  end
  
end
