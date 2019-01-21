class ComposerFor::PostTestGradations::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    build_and_set_post_test_gradation
    add_post_test_id_to_gradation
    run_validations
  end

  def permit_attributes
    @permited_attributes = @params.require('post_test_gradation')
    .permit(
      'from',
      'to',
      'message',
      'content_type',
      'content' => [
        'id'
      ]
    )
  end

  def build_and_set_post_test_gradation
    @post_test_gradation = PostTestGradation.factory.new
    .initialize_for_test_create(@permited_attributes)
    .get_result
  end

  def add_post_test_id_to_gradation
    @post_test_gradation.post_test_id = @params['post_test_id']
  end

  def run_validations
    @post_test_gradation.validation_service
    .set_scenarios(:for_test_create)
    .set_attributes(:post_test_id)
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
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @post_test_gradation)
    else
      raise e
    end

  end

end
