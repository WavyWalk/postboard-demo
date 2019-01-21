class AsJsonSerializer::VideoEmbed::Create
  
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
      methods: [:base_url]
    }
  end

  def error_options
    {
      methods: [:base_url, :errors]
    }
  end

end
