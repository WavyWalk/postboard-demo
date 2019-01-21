class Services::PostVotePoll::Factory


  def self.builder(attributes)
    model = ::PostVotePoll.new(attributes)
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