class ComposerFor::TestQuestions::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    build_and_set_test_question
    add_post_test_id_to_question
    run_validations
  end


  def permit_attributes
    @permitted_attributes = @params.require('test_question')
    .permit(
      'text',
      'content_type',
      'on_answered_m_content_type',
      'question_type', #unused for now
      'on_answered_msg',
      {
        'content' => [ 
          'id'
        ]
      },
      {
        'on_answered_m_content' => [
          'id'
        ]
      },
      {
        'test_answer_variants' => [
          'text',
          'answer_type',
          'content_type',
          'correct',
          'on_select_message',
          'content' => [
            'id'
          ]
        ]
      }
    )
  end

  def build_and_set_test_question
    test_question_factory = TestQuestion.factory.new
    .initialize_for_test_create(@permitted_attributes)
      
      
    test_question_factory
    .add_test_answer_variants( 
      build_test_answer_variants(
        @permitted_attributes['test_answer_variants']
      ) 
    )

    @test_question = test_question_factory.get_result
  end

  def build_test_answer_variants(attributes)
    attributes ||= []
    variants = []
    attributes.each do |variant_attributes|

      factory = TestAnswerVariant.factory.new
      .initialize_for_test_create(variant_attributes)
      
      variants << factory.get_result
    end
    variants
  end

  def add_post_test_id_to_question
    @test_question.post_test_id = @params['post_test_id']
  end

  def run_validations
    @test_question
      .validation_service
      .set_scenarios(:for_test_create)
      .set_attributes(:post_test_id)
      .validate
  end


  def compose
    @test_question.save!
    #@test_question.post_test.updater.serialize_necessary_fields_and_save_and_update_s_nodes_on_related_posts
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_question_created(@test_question)
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
