class ComposerFor::TestQuestions::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_test_question
    validate
  end

  def find_and_set_test_question
    @test_question = TestQuestion.find(@params['id'])
  end

  def validate
    @test_question
    .validation_service
    .set_scenarios(:destroy)
    .validate

    if !@test_question.valid?
      raise ActiveRecord::RecordInvalid.new(@test_question)
    end
  end

  def compose
    @test_question.destroy!
    #@test_question.post_test.updater.serialize_necessary_fields_and_save_and_update_s_nodes_on_related_posts
    Services::Post::SNodesUpdater::PostTestsRelated.when_test_question_destroyed(@test_question)
  end

  def resolve_success
    publish(:ok, @test_question)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @test_question)
    when ActiveRecord::RecordNotFound
      test_question = TestQuestion.new
      test_question.errors.add(:general, 'doe not exist')
      publish(:question_does_not_exist)
    else
      raise e
    end

  end

end
