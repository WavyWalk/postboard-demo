class ComposerFor::P_T_Personalities::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    set_personality
    assign_attributes
    validate
  end

  def permit_attributes
    @permitted_attributes = @params.require('p_t_personality')
      .permit(
        'title'
      )
  end

  def set_personality
    @personality = P_T_Personality.find(@params['id'])
  end

  def assign_attributes
    @personality.title = @permitted_attributes['title']
  end

  def validate
    @personality.validation_service.set_scenarios(:update).validate
  end

  def compose
    @personality.save!
  end

  def resolve_success
    publish(:ok, @personality)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @personality)
    else
      raise e
    end

  end

end
