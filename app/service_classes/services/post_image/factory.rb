class Services::PostImage::Factory

  def self.builder(attributes)
    model = ::PostImage.new(attributes)
    self.new(model)
  end

  def initialize(model)
    @model = model
  end

  def add_custom_error(*args)
    @model.add_custom_error(*args)
    self
  end

  def get_result
    @model
  end

end
