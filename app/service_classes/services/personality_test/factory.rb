class Services::PersonalityTest::Factory
  
  def initialize(model = ::PostTest.new)
    @model = model
  end  

  def initialize_for_create(attributes)
    @model.title = attributes['title']
    @model.thumbnail_id = (attributes['thumbnail'] ||= {})['id']
    @model.is_personality = true
    self
  end

  def add_user_id(id)
    @model.user_id = id
    self 
  end

  def add_test_questions(test_questions)
    @model.test_questions = test_questions
    self
  end

  def add_personalities(personalities)
    @model.p_t_personalities = personalities
    self
  end

  def get_result
    @model
  end
  
end
