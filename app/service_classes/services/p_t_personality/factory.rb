
class Services::P_T_Personality::Factory
  
  def initialize
    @model = ::P_T_Personality.new
  end  

  def initialize_for_personality_test_create(attributes)
    @model.title = attributes['title']
    @model.media_type = attributes['media_type']
    @model.media_id = (attributes['media'] ||= {})['id']
    self
  end


  def get_result
    return @model  
  end
  
end
