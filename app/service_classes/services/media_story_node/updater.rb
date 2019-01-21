class Services::MediaStoryNode::Updater
  
  def initialize(model)
    @model = model
  end

  def replace_media_node(attributes)
    
    if attributes['media_type'] == 'VideoEmbed'
      @media = Services::PostNode::Factory.initialize_video_embed_when_creating_post(attributes['media'])
      @model.media = @media
    else
      @model.media_id = (attributes['media'] ||= {})['id'] 
      @model.media_type = attributes['media_type']
    end

  end
  
end
