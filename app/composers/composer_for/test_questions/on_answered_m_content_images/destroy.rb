class ComposerFor::TestQuestions::OnAnsweredMContentImages::Destroy < ComposerFor::Base

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
    
  end

  def assign_attributes
    
  end

  def compose
    
  end

  def resolve_success
  
  end

  def resolve_fail(e)
    
    raise e

  end

end
