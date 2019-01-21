class AsJsonSerializer::PersonalityTests::Create
  
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
          p_t_personalities: 
          {
            include: [
              {
                media: {
                  methods: [:post_size_url, :link]
                }
              }
            ]
          }
        },
        {
          test_questions:
          {
            include: 
            [
              {
                content: {methods: [:post_size_url]}
              },
              {
                test_answer_variants: {
                  include: [:personality_scales]
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
        {
          thumbnail: {methods: [:post_size_url]}
        },
        {
          p_t_personalities: 
          {
            methods: [:errors],
            include: [
              {
                media: {
                  methods: [:post_size_url, :link, :errors]
                }
              }
            ]
          }
        },
        {
          test_questions:
          {
            methods: [:errors],
            include: 
            [
              {
                content: {methods: [:post_size_url, :errors]}
              },
              {
                test_answer_variants: {
                  methods: [:errors],
                  include: [
                    {
                      personality_scales: {methods: [:errors]}
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    }
  end

end
