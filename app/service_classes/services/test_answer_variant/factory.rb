class Services::TestAnswerVariant::Factory

  def initialize(model = ::TestAnswerVariant.new)
    @model = model
  end

  def initialize_for_test_create(attributes)
    @model.text = attributes['text']
    @model.content_type = attributes['content_type']
    @model.answer_type = attributes['answer_type']
    @model.correct = attributes['correct']
    @model.on_select_message = attributes['on_select_message']

    attributes['content'] ||= {}

    @model.content_id = attributes['content']['id']
    
    self
  end


  def initialize_for_personality_test_create(attributes)
    @model.text = attributes['text']
    @model.content_type = attributes['content_type']

    attributes['content'] ||= {}

    @model.content_id = attributes['content']['id']

    self
  end

  def assign_test_question_id(test_question_id)
    @model.test_question_id = test_question_id
    self
  end

  def add_personality_scales(personality_scales)
    @model.personality_scales = personality_scales
    self
  end

  def get_result
    @model
  end

end