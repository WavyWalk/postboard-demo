class ComposerFor::P_T_Personalities::Destroy < ComposerFor::Base

  def initialize(controller)
    @controller = controller
    @params = controller.params
  end

  def before_compose
    set_p_t_personality_to_destroy
    validate    
  end

  def set_p_t_personality_to_destroy
    @p_t_personality_to_destroy = ::P_T_Personality.find(@params['id'])
  end

  def validate
    @p_t_personality_to_destroy.validation_service.set_scenarios(:destroy).validate      
  end

  #personality_scales destroyed cascadely
  def compose
    if @p_t_personality_to_destroy.valid?
      @p_t_personality_to_destroy.destroy!
    else
      raise ActiveRecord::RecordInvalid.new(@p_t_personality_to_destroy)
    end
  end

  def resolve_success
    publish(:ok, @p_t_personality_to_destroy)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @p_t_personality_to_destroy)
    else
      raise e
    end

  end

end
