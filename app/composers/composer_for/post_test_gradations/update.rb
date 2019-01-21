class ComposerFor::PostTestGradations::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post_test_gradation!
    permit_attributes
    assign_attributes
    run_validations
  end

  def find_and_set_post_test_gradation!
    @post_test_gradation = PostTestGradation
    .where(id: @params['id']).first

    unless @post_test_gradation
      fail_immediately(:post_test_gradation_does_not_exist)
    end
  end

  def permit_attributes

    @permitted_attributes = @params
    .require('post_test_gradation')
    .permit(
      'from',
      'to',
      'message'
    )

  end

  def assign_attributes
    @post_test_gradation
    .updater
    .regular_update(@permitted_attributes)
  end

  def run_validations
    @post_test_gradation
    .validation_service
    .set_scenarios(:regular_update)
    .validate
  end

  def compose
    @post_test_gradation.save!
    @post_test_gradation.post_test.updater.serialize_necessary_fields_and_save_and_update_s_nodes_on_related_posts
  end

  def resolve_success
    publish(:ok, @post_test_gradation)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_test_gradation)
    when :post_test_gradation_does_not_exist
      post_test_gradation = PostTestGradation.new
      post_test_gradation.errors.add(:general, 'does not exist')
      publish(:post_test_gradation_does_not_exist, post_test_gradation)
    else
      raise e
    end

  end

end