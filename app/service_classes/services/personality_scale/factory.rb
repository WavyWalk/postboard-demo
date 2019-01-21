class Services::PersonalityScale::Factory
  
  def initialize(model = ::PersonalityScale.new)
    @model = model
  end

  def initialize_for_personality_test_create( attributes )
    @model.scale = attributes['scale']
    #@model.p_t_personality_id = personality.id
    self
  end

  def initialize_for_p_t_personality_create( attributes )
    @model.scale = 5
    @model.test_answer_variant_id = attributes[:test_answer_variant_id]
    self
  end

  def assign_p_t_personality_id(p_t_personality_id)
    @model.p_t_personality_id = p_t_personality_id
    self
  end

  def get_result
    return @model
  end
  
end
