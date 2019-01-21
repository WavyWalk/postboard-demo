class ComposerFor::TestQuestions::OnAnsweredMContentImages::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_on_answered_m_content_image_id
    find_and_set_test_question
    assign_attributes
    validate
  end

  def set_on_answered_m_content_image_id
    @on_answered_m_content_image_id = @params['id'] 
  end

  def find_and_set_test_question
    @test_question = TestQuestion.where(id: @params['test_question_id']).first
    unless @test_question
      fail_immediately(:question_does_not_exist)
    end
  end


  def assign_attributes
    @test_question.on_answered_m_content_id = @on_answered_m_content_image_id
    @test_question.on_answered_m_content_type = 'PostImage'
  end

  def validate
    @test_question.validation_service.set_attributes(:on_answered_m_content_id).validate
  end

  def compose
    @test_question.save!
  end

  def resolve_success
    publish :ok, @test_question
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_question_on_answered_m_content_updated(@test_question)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid 
      publish(:validation_error, @test_question)
    when :question_does_not_exist
      post_image = PostImage.new
      post_image.errors.add(:general, 'non existant')
      publish(:question_does_not_exist, post_image)
    else
      raise e
    end

  end

end
