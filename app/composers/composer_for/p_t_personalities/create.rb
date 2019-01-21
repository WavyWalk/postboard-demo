class ComposerFor::P_T_Personalities::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    assign_attributes
    assign_post_test_id
    set_personality_scales_to_create
    assign_personality_scales
    validate
  end

  def permit_attributes
    @permitted_attributes = @params.require('p_t_personality').permit(
      'title',
      'media_type',
      'media' => [
        'id'
      ]
    )
  end

  def assign_attributes
    @p_t_personality = ::P_T_Personality.factory
      .initialize_for_personality_test_create(@permitted_attributes)
      .get_result
  end

  def assign_post_test_id
    @p_t_personality.post_test_id = @params['personality_test_id']
  end

  def set_personality_scales_to_create
    @personality_scales = []
    variants = TestAnswerVariant.joins(:test_question).where('test_questions.post_test_id = ?', @params['personality_test_id'])
    variants.each do |variant|
      personality_scale = ::PersonalityScale.factory.new
        .initialize_for_p_t_personality_create(
          {
            test_answer_variant_id: variant.id
          }
        ).get_result

      @personality_scales << personality_scale
    end
  end

  def assign_personality_scales
    @p_t_personality.personality_scales = @personality_scales
  end

  def validate
    @p_t_personality.validation_service
      .set_scenarios(:create)
      .validate
  end

  def compose
    @p_t_personality.save!
  end

  def resolve_success
    publish(:ok, @p_t_personality)
  end

  def resolve_fail(e)
    
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @p_t_personality)
    else
      raise e
    end

  end

end
