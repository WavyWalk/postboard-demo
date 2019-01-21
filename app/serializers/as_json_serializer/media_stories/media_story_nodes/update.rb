class AsJsonSerializer::MediaStories::MediaStoryNodes::Update
  
  def initialize(model)
    @model = model
  end
  
  def success
    json = @model.as_json
    json['media'] = media_as_json
    json
  end

  def error
    json = @model.as_json(methods: [:errors])
    json['media'] = media_as_json_with_errors
    json
  end

 private

  def media_as_json
    case @model.media_type
    when 'PostImage'
      return @model.media.as_json(methods: [:post_size_url])
    when 'PostGif'
      return @model.media.as_json(methods: [:post_gif_url])
    when 'VideoEmbed'
      return @model.media.as_json
    else
      return media_as_json
    end
  end

  def media_as_json_with_errors
    case @model.media_type
    when 'PostImage'
      return @model.media.as_json(methods: [:post_size_url, :errors])
    when 'PostGif'
      return @model.media.as_json(methods: [:post_gif_url, :errors])
    when 'VideoEmbed'
      return @model.media.as_json(methods: [:errors])
    else
      return @model.media.as_json(methods: [:errors])
    end
  end

end
