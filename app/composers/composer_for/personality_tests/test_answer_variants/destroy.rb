class ComposerFor::PersonalityTests::TestAnswerVariants::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_test_answer_variant
    validate
  end

  def find_and_set_test_answer_variant
    @test_answer_variant = ::TestAnswerVariant.find(@params['id'])
  end

  def validate
    @test_answer_variant.validation_service.set_scenarios(:personality_test_destroy).validate            
  end

  def compose
    if @test_answer_variant.valid?
      @test_answer_variant.destroy
    else
      raise ActiveRecord::RecordInvalid.new(@test_answer_variant)
    end
  end

  def resolve_success
    publish(:ok, @test_answer_variant)
  end

  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @test_answer_variant)
    else
      raise e
    end
  end

end
