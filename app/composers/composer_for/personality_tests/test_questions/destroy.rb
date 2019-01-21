class ComposerFor::PersonalityTests::TestQuestions::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_test_question
    validate
  end

  def find_and_set_test_question
    @test_question = ::TestQuestion.find(@params['id'])
  end

  def validate
    unless @test_question.post_test.id == @params['personality_test_id'].to_i
      @test_question.add_custom_error(:general, "forbidden")
    end
    if @test_question.post_test.test_questions.size < 1
      @test_question.add_custom_error(:general, "can't delete, should be at least one question on test")
    end
  end

  def compose
    if @test_question.valid?
      @test_question.destroy!
    else
      raise ActiveRecord::RecordInvalid.new(@test_question)
    end
  end

  def resolve_success
    publish(:ok, @test_question)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @test_question)
    else
      raise e
    end

  end

end
