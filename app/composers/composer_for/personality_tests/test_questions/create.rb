class ComposerFor::PersonalityTests::TestQuestions::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_permitted_attributes
    build_and_set_test_question
    validate_test_question
  end

  def set_permitted_attributes
    @permitted_attributes = @params.require('test_question')
      .permit(
        'text',
        'content_type',
        {
          'content' => [
            'id'
          ]
        },
        'test_answer_variants' => [
          'text',
          'content_type',
          'content' => [
            'id'
          ],
          'personality_scales' => [
            'scale',
            'p_t_personality_id'
          ]
        ]
      )
  end

  def build_and_set_test_question
    test_question_factory = TestQuestion.factory.new
    test_question_factory
      .initialize_for_personality_test_create( @permitted_attributes )
      .assign_post_test_id( @params['personality_test_id'] )
      .add_test_answer_variants(
        build_test_answer_variants(
          @permitted_attributes['test_answer_variants']
        )
      )
    @test_question = test_question_factory.get_result
  end

  def build_test_answer_variants(test_answer_variants_attributes)
    variants = []
    (test_answer_variants_attributes ||= []).each do |variant_attributes|
      variant_factory = TestAnswerVariant.factory.new
        .initialize_for_personality_test_create(variant_attributes)
        .add_personality_scales(
          build_personality_scales(
            variant_attributes['personality_scales']  
          )
        )

      variants << variant_factory.get_result
    end

    return variants
  end


  def build_personality_scales(attributes)
    attributes ||= []
    personality_scales = []

    attributes.each do |personality_scale_attributes|
      
      factory = PersonalityScale.factory.new
        .initialize_for_personality_test_create(personality_scale_attributes)
        .assign_p_t_personality_id( personality_scale_attributes['p_t_personality_id'] )
      
      personality_scales << factory.get_result        

    end

    return personality_scales
  end

  
  def validate_test_question
    @test_question.validation_service.set_scenarios(:personality_test_create_separate).validate
  end

  def compose
    @test_question.save!
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
