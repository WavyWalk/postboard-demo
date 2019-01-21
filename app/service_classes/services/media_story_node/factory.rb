class Services::MediaStoryNode::Factory
  
  def initialize
    @model = ::MediaStoryNode.new    
  end  
 
  def initialize_for_media_story_create(attributes)
    @model.annotation = attributes['annotation']
    @model.media_type = attributes['media_type']

    if attributes['media_type'] == 'VideoEmbed'
      media = Services::PostNode::Factory.initialize_video_embed_when_creating_post(attributes['media'])
      @model.media = media
    else  
      @model.media_id = (attributes['media'] ||= {})['id']
    end

    self
  end

  def add_media_story_id(id)
    @model.media_story_id = id
    self
  end
  
  def get_result
    @model
  end

end
