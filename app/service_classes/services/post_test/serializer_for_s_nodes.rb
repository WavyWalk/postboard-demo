class Services::PostTest::SerializerForSNodes
  
  def self.serialize_when_post_test_updated(post_test)
    post_test.as_json
  end  

  def self.serialize_when_test_question_created(test_question)
    ::AsJsonSerializer::TestQuestions::Create.new(test_question).success
  end

  def self.serialize_when_update_test_question(test_question)
    test_question.as_json
  end

  def self.serialize_when_test_answer_variant_created(test_answer_variant)
    test_answer_variant.as_json(include: [:content])
  end

  def self.serialize_when_test_answer_variant_updated(test_answer_variant)
    test_answer_variant.as_json
  end

  def self.serialize_when_test_answer_variant_content_updated(test_answer_variant)
    test_answer_variant.as_json(include: [:content])
  end

  def self.serialize_when_test_answer_variant_content_destroyed(test_answer_variant)
    test_answer_variant.as_json
  end

  
  def self.serialize_when_post_test_thumbnail_updated(post_test)
    post_test.as_json(include: [:thumbnail])
  end

  def self.serialize_when_test_question_content_image_updated(test_question)
    test_question.as_json(include: [:content])
  end

  def self.serialize_when_test_question_on_answered_m_content_updated(test_question)
    test_question.as_json(include: [:on_answered_m_content])
  end

end
