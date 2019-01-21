class Services::PostTest::Factory

  def initialize(model = ::PostTest.new)
    @model = model
  end

  def initialize_for_create(attributes)
    @model.title = attributes['title']
    @model.thumbnail_id = (attributes['thumbnail'] ||= {})['id']
    self
  end

  def add_test_questions(test_questions)
    @model.test_questions = test_questions
    self
  end

  def add_post_test_gradations(post_test_gradations)
    @model.post_test_gradations = post_test_gradations
    self
  end

  def add_user_id(id)
    @model.user_id = id
    self
  end

  def get_result
    @model
  end

  def self.builder(attributes)
    model = ::PostVotePoll.new(attributes)
    self.new(model)
  end

  def get_result
    @model
  end

end