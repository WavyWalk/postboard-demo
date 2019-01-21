class TestAnswerVariant < Model
  register

  attributes :id, :text, :answer_type, :content_type, :s_content, :correct, :on_select_message, :test_question_id

  has_one :test_question, class_name: 'TestQuestion'
  has_one :content, polymorphic_type: :content_type, aliases: [:s_content_json]
  has_many :personality_scales, class_name: 'PersonalityScale'

  route :create, post: 'test_questions/:test_question_id/test_answer_variants'
  route :update, {put: 'test_questions/:test_question_id/test_answer_variants/:id'}, {defaults: [:test_question_id, :id]} 
  route :destroy, {delete: "test_answer_variants/:id"}, {defaults: [:id]}
  route :personality_test_create, {post: 'personality_tests/test_answer_variants'}
  route :personality_test_destroy, {
    delete: 'personality_tests/test_answer_variants/:id'
  }, {
    defaults: [:id]
  }

  def before_route_personality_test_create(r)
    before_route_create(r)    
  end

  def after_route_personality_test_create(r)
    after_route_create(r)
  end

  def after_route_personality_test_destroy(r)
    after_route_update(r)
  end

  attr_accessor :is_selected

end
