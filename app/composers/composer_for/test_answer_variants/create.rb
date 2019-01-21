class ComposerFor::TestAnswerVariants::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    build_and_set_test_variant
    add_test_question_id_to_variant
    run_validations
  end

  def permit_attributes
    @permitted_attributes = @params.require('test_answer_variant')
    .permit(
      'text',
      'answer_type',
      'content_type',
      'correct',
      'on_select_message',
      'content' => [
        'id'
      ]
    )
  end

  def build_and_set_test_variant
    factory = TestAnswerVariant.factory.new
    .initialize_for_test_create(@permitted_attributes)

    @test_answer_variant = factory.get_result
  end

  def add_test_question_id_to_variant
    @test_answer_variant.test_question_id = @params['test_question_id']
  end

  def run_validations
    @test_answer_variant
    .validation_service
    .set_scenarios(:for_test_create)
    .set_attributes(:test_question_id)
    .validate
  end

  def compose
    @test_answer_variant.save!
    Services::Post::SNodesUpdater::PostTestsRelated.when_test_answer_variant_created(@test_answer_variant)
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
