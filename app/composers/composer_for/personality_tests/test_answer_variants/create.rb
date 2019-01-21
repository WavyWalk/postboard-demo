class ComposerFor::PersonalityTests::TestAnswerVariants::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_permitted_attributes
    build_and_set_test_answer_variant
    validate
  end

  def set_permitted_attributes
    @permitted_attributes = @params.require('test_answer_variant')
      .permit(
        'text',
        'test_question_id',
        'content_type',
        'content' => [
          'id'
        ],
        'personality_scales' => [
          'scale',
          'p_t_personality_id'
        ]
      )
  end

  def build_and_set_test_answer_variant
    variant_factory = TestAnswerVariant.factory.new
        .initialize_for_personality_test_create(@permitted_attributes)
        .add_personality_scales(
          build_personality_scales(
            @permitted_attributes['personality_scales']  
          )
        )
        .assign_test_question_id(@permitted_attributes['test_question_id'])
    
    @test_answer_variant = variant_factory.get_result
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

  def validate
    @test_answer_variant
      .validation_service
      .set_scenarios(:personality_test_create_separate)
      .validate
  end

  def compose
    @test_answer_variant.save!
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
