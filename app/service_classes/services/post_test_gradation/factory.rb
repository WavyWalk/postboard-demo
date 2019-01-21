class Services::PostTestGradation::Factory

  def initialize(model = ::PostTestGradation.new)
    @model = model
  end

  def initialize_for_test_create(attributes)
    @model.from = attributes['from']
    @model.to = attributes['to']
    @model.content_id = (attributes['content'] ||= {})['id']
    @model.content_type = attributes['content_type']
    @model.message = attributes['message']
    self
  end


  def get_result
    @model
  end

end