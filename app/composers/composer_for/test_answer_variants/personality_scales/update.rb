class ComposerFor::TestAnswerVariants::PersonalityScales::Update < ComposerFor::Base

  def initialize(controller)
    @controller = controller
    @params = controller.params
  end

  def before_compose
    permit_attributes
    find_and_set_personality_scale
    assign_attributes
    validate
  end

  def permit_attributes
    @permitted_attributes = @params.require('personality_scale')
      .permit('scale')
  end

  def find_and_set_personality_scale
    @personality_scale = PersonalityScale.find(@params['id']) 
  end

  def assign_attributes
    @personality_scale.scale = @permitted_attributes['scale']
  end

  def validate
    @personality_scale.validation_service.set_attributes(:scale).validate
  end

  def compose
    @personality_scale.save!
  end

  def resolve_success
    publish(:ok, @personality_scale)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @personality_scale)
    else
      raise e
    end

  end

end
