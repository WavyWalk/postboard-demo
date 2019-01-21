class ComposerFor::PostGifs::Create < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @params = params
    @controller = controller
    @options = options
  end

  def before_compose
    permit_attributes
    assign_attributes
  end

  def permit_attributes
    @permitted_attributes =
      @params
        .require(:post_gif)
        .permit(:file)

  end

  def assign_attributes
    @model.attributes = @permitted_attributes
    @model.user_id = @controller.current_user.id
    @model.orphaned = true
  end

  def compose
    @model.save!
  end

  def resolve_success
    publish(:ok, @model)
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      publish :validation_error, @model
    else
      raise e
    end

  end

end
