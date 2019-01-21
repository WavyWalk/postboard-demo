class PostTest < Model
  register

  attributes :id, :s_questions, :s_thumbnail, 
             :title, :s_gradations, :is_personality

  has_one :thumbnail, class_name: 'PostImage'
  has_many :test_questions, class_name: 'TestQuestion'
  has_one :user, class_name: 'User'
  has_many :post_test_gradations, class_name: 'PostTestGradation'
  has_many :p_t_personalities, class_name: 'P_T_Personality'

  route :create, post: "post_tests"
  route :Show, get: "post_tests/:id"
  route :Personality_test_show, get: "personality_tests/:id"
  route :update, {put: 'post_tests/:id'}, {defaults: [:id]}
  route :create_personality, {post: 'personality_tests'}
  route :Personality_test_edit, {get: "personality_tests/:id/edit"} 
  route :destroy, {delete: 'post_tests/:id'}, {defaults: [:id]}


  def self.after_route_personality_test_show(r)
    self.after_route_show(r)
  end

  def before_route_create_personality(r)
    self.before_route_create(r)
  end

  def after_route_create_personality(r)
    self.after_route_create(r)
  end

  def self.after_route_personality_test_edit(r)
    self.after_route_show(r)
  end


  def init(attributes)
    if x = attributes[:s_questions]
      self.s_questions = TestQuestion.parse(JSON.parse(x))
    end
    if x = attributes[:s_thumbnail]
      self.s_thumbnail = PostImage.parse(JSON.parse(x))
    end
    if x = attributes[:s_gradations]
      self.s_gradations = PostTestGradation.parse(JSON.parse(x))
    end
  end

end
