class TestQuestion < Model

  register

  attributes :id, :content_type, :s_content, :question_type, :s_test_answer_variants, 
             :text, :on_answered_msg, :content_id, :on_answered_m_content_id, :on_answered_m_content_type,
             :post_test_id

  has_one :post_test, class_name: 'PostTest'
  has_many :test_answer_variants, class_name: 'TestAnswerVariant'
  has_one :content, polymorphic_type: :content_type, aliases: [:s_content_json]
  has_one :on_answered_m_content, polymorphic_type: :on_answered_m_content_type, aliases: [:s_on_answered_m_content_json]
  has_one :s_on_answered_m_content, polymorphic_type: :on_answered_m_content_type 
  

  route :create, post: 'post_tests/:post_test_id/test_questions'
  route :update, {
    put: 'post_tests/:post_test_id/test_questions/:id'
  }, {
    defaults: [:post_test_id, :id]
  }
  route :destroy, {delete: 'test_questions/:id'}, {defaults: [:id]} 
  route :personality_test_create, {
    post: 'personality_tests/:personality_test_id/test_questions'
  }
  route :personality_test_destroy, {
    delete: 'personality_tests/:personality_test_id/test_questions/:id'
  }, {
    defaults: [:id]
  }

  def before_route_personality_test_create(r)
    before_route_create(r)
  end

  def after_route_personality_test_create(r)
    after_route_create(r)
  end

  def before_route_personality_test_destroy(r)
        
  end

  def after_route_personality_test_destroy(r)
    after_route_update(r)
  end

  attr_accessor :answered_correct

end
