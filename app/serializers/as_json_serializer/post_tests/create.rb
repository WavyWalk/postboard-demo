class AsJsonSerializer::PostTests::Create

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
        {
          thumbnail: {methods: [:post_size_url]}
        },
        {
          post_test_gradations:
          {

            methods: [:post_test_url],
            include:
            [
              {
                content: {methods: [:post_size_url]}
              }
            ]
          }
        },
        {
          test_questions:
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
        }
      ]
    }
  end

  def error_options
    {
      methods: [:errors],
      include:
      [
        :thumbnail,
        {
          test_questions:
          {
            methods: [:errors],
            include:
            [
              :content,
              test_answer_variants:
              {
                methods: [:errors],
                include:
                [
                  :content
                ]
              }
            ]
          }
        },
        {
          post_test_gradations:
          {
            methods: [:errors],
            include:
            [
              :content
            ]
          }
        }
      ]
    }
  end

end
