class ComposerFor::TestAnswerVariants::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_answer_variant!
    permit_attributes
    assign_attributes
    run_validations
  end

  def find_and_set_answer_variant!
    @answer_variant = TestAnswerVariant
    .where(id: @params['id']).first

    unless @answer_variant
      fail_immediately(:answer_variant_does_not_exist)
    end
  end

  def permit_attributes

    @permitted_attributes = @params
    .require('test_answer_variant')
    .permit(
      'text',
      'correct',
      'on_select_message'
    )

  end

  def assign_attributes
    @answer_variant
    .updater
    .regular_update(@permitted_attributes)
  end

  def run_validations
    @answer_variant
    .validation_service
    .set_scenarios(:regular_update)
    .validate
  end

  def compose
    @answer_variant.save!
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_answer_variant_updated(@answer_variant)
  end

  def resolve_success
    publish(:ok, @answer_variant)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @answer_variant)
    when :variant_does_not_exist
      variant = TestAnswerVariant.new
      variant.errors.add(:general, 'does not exist')
      publish(:variant_does_not_exist, variant)
    else
      raise e
    end

  end

end
