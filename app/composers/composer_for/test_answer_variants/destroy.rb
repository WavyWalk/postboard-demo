class ComposerFor::TestAnswerVariants::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_test_answer_variant
    validate
  end

  def find_and_set_test_answer_variant
    @test_answer_variant = TestAnswerVariant.find(@params['id'])
  end

  def validate
    @test_answer_variant
    .validation_service
    .set_scenarios(:destroy)
    .validate

    if !@test_answer_variant.valid?
      raise ActiveRecord::RecordInvalid.new(@test_answer_variant)
    end
  end

  def compose
    @test_answer_variant.destroy!
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_answer_variant_destroyed(@test_answer_variant)
  end

  def resolve_success
    publish(:ok, @test_answer_variant)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @test_answer_variant)
    when ActiveRecord::RecordNotFound
      test_answer_variant = TestAnswerVariant.new
      test_answer_variant.errors.add(:general, 'does not exist')
      publish(:variant_does_not_exist)
    else
      raise e
    end

  end


end
