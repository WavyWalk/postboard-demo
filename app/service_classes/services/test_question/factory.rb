class Services::TestQuestion::Factory

  def initialize(model = ::TestQuestion.new)
    @model = model
  end

  def initialize_for_test_create(attributes)
    @model.text = attributes['text']
    @model.content_type = attributes['content_type']
    @model.content_id = (attributes['content'] ||= {})['id']
    @model.question_type = attributes['question_type']
    @on_wrong_select_msg = attributes['on_wrong_select_msg']

    if ctt = attributes['on_answered_m_content_type']
      @model.on_answered_m_content_type = ctt
      @model.on_answered_m_content_id = (attributes['on_answered_m_content'] ||= {})['id']
    end

    @model.on_answered_msg = attributes['on_answered_msg']
    
    self
  end

  def add_test_answer_variants(test_answer_variants)
    @model.test_answer_variants = test_answer_variants
    self
  end

  def add_variants_as_personality_test( test_answer_variants )
    @model.test_answer_variants = test_answer_variants
    self
  end


  def initialize_for_personality_test_create(attributes)
    @model.text = attributes['text']
    @model.content_type = attributes['content_type']
    @model.content_id = (attributes['content'] ||= {})['id']
    self
  end

  def assign_post_test_id(post_test_id)
    @model.post_test_id = post_test_id
    self
  end


  def get_result
    @model
  end

end