class ComposerFor::P_T_Personalities::Medias::Update < ComposerFor::Base

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
    @permitted_attributes = @params.require('p_t_personality').permit(
      'media_type',
      'media' => [
        'id'
      ]
    )
  end

  def set_personality
    @personality = P_T_Personality.find(@params['p_t_personality_id'])
  end

  def assign_attributes
    @personality.media_type = @permitted_attributes['media_type']
    @personality.media_id = (@permitted_attributes['media'] ||= {})['id']
  end

  def validate
    @personality.validation_service.set_scenarios(:medias_update).validate
  end

  def compose
    @personality.save!
  end

  def resolve_success
    publish(:ok, @personality)
  end

  def resolve_fail(e)
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @personality)
    else
      raise e
    end
  end

end
