class ComposerFor::PersonalityTests::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_permitted_attributes
    build_and_set_post_test
    #add_test_questions
    #validate_final
    run_pre_questions_add_validations
  end

  def set_permitted_attributes
    @permitted_attributes = @params.require('post_test').permit(
      'title',
      {
        'thumbnail' => [
          'id'
        ]
      },
      {
        'p_t_personalities' => [
          'title',
          'media_type',
          'media' => [
            'id'
          ]
        ]
      },
      {
        'test_questions' => [
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
              'scale'
            ]
          ]
        ]
      }
    )
  end

  def build_and_set_post_test

    personalities = build_personalities
    questions = build_questions

    test_factory = PostTest
      .personality_factory.new
      .initialize_for_create( @permitted_attributes )
      .add_user_id( @controller.current_user.id )
      .add_personalities( personalities )
      .add_test_questions( questions )

    @post_test = test_factory.get_result
  end

  def build_personalities
    p_t_personalities = []
    p_t_personalities_attributes = @permitted_attributes['p_t_personalities']
    
    (p_t_personalities_attributes ||= []).each do |individual_p_t_personality_attributes|
      
      p_t_personality = ::P_T_Personality.factory
        .initialize_for_personality_test_create(
          individual_p_t_personality_attributes
        )
        .get_result

      p_t_personalities << p_t_personality
    
    end

    return p_t_personalities
  end

  def build_questions
    attributes ||= []
    test_questions = []

    (@permitted_attributes['test_questions'] ||= []).each do |question_attributes|

      test_question_factory = TestQuestion.factory.new
        
      test_question_factory
        .initialize_for_personality_test_create( question_attributes )
        .add_variants_as_personality_test(
          build_variants(question_attributes)
        )
       

      test_questions << test_question_factory.get_result
    end    
    
    test_questions
    
  end

  def build_variants(question_attributes)
    variants = []
    (question_attributes['test_answer_variants'] ||= []).each do |variant_attributes|
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
      
      personality_scales << factory.get_result        

    end

    return personality_scales
  end
  

  def run_pre_questions_add_validations
    @post_test.personality_test_validation_service
      .set_scenarios(:create)
      .validate

    @post_test.p_t_personalities.each do |p_t_personality|
      p_t_personality
        .validation_service
        .set_scenarios(:personality_test_create)
        .validate
    end  

    @post_test.test_questions.each do |test_question|
      test_question
        .validation_service
        .set_scenarios(:personality_test_create)
        .validate

      test_question.test_answer_variants.each do |answer_variant|
        answer_variant.validation_service.set_scenarios(:personality_test_create).validate
        answer_variant.personality_scales.each do |personality_scale|
          personality_scale.validation_service.set_scenarios(:personality_test_create).validate
        end
      end
    end

  end

  def compose
    @post_test.save!
    assign_p_t_personality_ids_to_personality_scales
  end


  def assign_p_t_personality_ids_to_personality_scales
    @post_test.test_questions.each do |test_question|
      test_question.test_answer_variants.each do |variant|
        index = -1
        variant.personality_scales.each do |personality_scale|
          index +=1 
          personality_scale.p_t_personality_id = @post_test.p_t_personalities[index].id
          personality_scale.save!
        end
      end
    end
    byebug
  end

  def resolve_success
    publish(:ok, @post_test)
  end

  def resolve_fail(e)
    
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @post_test)
    else
      raise e
    end

  end

end
