class PostGif < Model

  register

  attributes :id, :file, :post_gif_url, :dimensions, :post_node_id, :subtitles, :base_url

  #has_many :subtitles, class_name: 'Subtitle'

  route 'create', {post: "post_gifs"}

  route 'add_subtitles', {post: "post_gifs/add_subtitles"}

  def before_route_add_subtitles(r)
    #r.req_options = {id: self.id, }
  end

  def post_gif_url
    if base_url
      base_url.gsub('/original/', '/post_gif/').gsub('.gif', '.ogg')
    else
      attributes[:post_gif_url]
    end
  end

  def after_route_add_subtitles(r)
    if r.response.ok?
      r.promise.resolve self.class.parse(r.response.json)
    end
  end

  def validate_file
    self.has_file = true
  end

  # def subtitles_to_json!
  #   self.subtitles = self.subtitles.to_json
  # end

  def serialize_subtitles!
    parsed_subtitles = JSON.parse(self.subtitles).map do |subtitle|
      Subtitle.new(subtitle)
    end
    # if !subtitles.is_a?(Array)
    #
    # end
    self.subtitles = parsed_subtitles
  rescue Exception => e
    self.subtitles = nil
  end

  def init
    if self.subtitles
      serialize_subtitles!
    end
  end

end
