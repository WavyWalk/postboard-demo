class AsJsonSerializer::MediaStories::Create
  
  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end
  
  def success
    json = @model.as_json

    json['media_story_nodes'] = []

    @model.media_story_nodes.each do |media_story_node|
      case media_story_node.media_type
      when 'PostImage'
        json['media_story_nodes'] << media_story_node.as_json(include: [{media: {methods: [:post_size_url]}}])
      when 'PostGif'
        json['media_story_nodes'] << media_story_node.as_json(include: [{media: [methods: [:post_gif_url]]}])
      when 'VideoEmbed'
        json['media_story_nodes'] << media_story_node.as_json(include: [:media]) 
      else
        json['media_story_nodes'] << media_story_node.as_json(include: [:media])
      end
    end

    json

  end

  def error
    json = @model.as_json(methods: [:errors])

    json['media_story_nodes'] = []
    
    @model.media_story_nodes.each do |media_story_node|
      case media_story_node.media_type
      when 'PostImage'
        json['media_story_nodes'] << media_story_node.as_json(methods: [:errros], include: [{media: {methods: [:post_size_url, :errors]}}])
      when 'PostGif'
        json['media_story_nodes'] << media_story_node.as_json(methods: [:errors], include: [{media: [methods: [:post_gif_url, :errors]]}])
      when 'VideoEmbed'
        json['media_story_nodes'] << media_story_node.as_json(methods: [:errors], include: [media: {methods: [:errors]}]) 
      else
        json['media_story_nodes'] << media_story_node.as_json(methods: [:errors], include: [:media])
      end
    end
    
    json
  end


end
