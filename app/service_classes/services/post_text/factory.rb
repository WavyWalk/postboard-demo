class Services::PostText::Factory

  def self.build(attributes = {})
    model = PostText.new(attributes)
    self.new(model)
  end

  def initialize(model)
    @model = model
    self
  end

  def sanitize_content(*args)
    @model.content = Services::PostTextSanitizer.sanitize_post_text_content(@model.content)
    self
  end

  def get_result
    @model
  end

end
