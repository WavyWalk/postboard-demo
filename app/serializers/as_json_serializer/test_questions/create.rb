class AsJsonSerializer::TestQuestions::Create
  
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
      include:
      [
        :content,
        :on_answered_m_content,
        {
          test_answer_variants:
          {
            include:
            [
              :content
            ]
          }
        }
      ]
    }
  end

  def error_options
    {
      methods: [:errors],
      include: 
      [
        {
          content: 
          {
            methods: 
            [
              :errors
            ]
          }
        }, 
        {
          test_answer_variants: 
          {
            methods: [:errors],
            include: 
            [
              content: 
              {
                methods: 
                [
                  :errors
                ]
              }
            ]
          }
        }
      ]
    }
  end

end
