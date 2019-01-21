class ComposerFor::PostImage::Create < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @params = params
    @controller = controller
    @options = options
  end

  def before_compose
    permit_attributes
    assign_attributes
    validate
    #attached file is validated from model level attachment validation
  end

  def permit_attributes
    @permitted_attributes =
      @params
        .require(:post_image)
        .permit(
          :file,
          :source_name,
          :alt_text
          #:source_link,
        )
  end

  def assign_attributes
    @model.attributes = @permitted_attributes
    #sets as orphaned for background cleaning of assets if will not be used
    #in future e.g. in as post node or else
    @model.orphaned = true
  end

  def validate
    @model.validation_service.set_scenarios(:create).validate
  end

  def compose
    @model.save!
    @model.updater.assign_file_url
    @model.save!
  end

  def resolve_success
    publish :ok, @model
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
