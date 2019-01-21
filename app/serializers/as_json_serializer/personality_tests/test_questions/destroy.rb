class AsJsonSerializer::PersonalityTests::TestQuestions::Destroy
  
  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end
  
  def success
    @model.as_json(success_options)
  end

  def error
    @model.as_json(error_options)
  end

 private

  def success_options
    {

    }
  end

  def error_options
    {
      methods: [:errors]
    }
  end

end
