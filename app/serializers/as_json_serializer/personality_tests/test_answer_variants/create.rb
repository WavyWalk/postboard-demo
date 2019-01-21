class AsJsonSerializer::PersonalityTests::TestAnswerVariants::Create
  
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
      include: [
        :personality_scales, 
        {content: {methods: [:base_url]}}
      ]
    }
  end

  def error_options
    {
      methods: [:errors],
      include: [
        {
          personality_scales: {methods: [:errors]}
        },
        {
          content: {methods: [:base_url]}
        }
      ]

    }
  end

end
