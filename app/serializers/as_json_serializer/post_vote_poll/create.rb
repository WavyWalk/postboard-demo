class AsJsonSerializer::PostVotePoll::Create
  
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
          m_content: 
          {
            methods: [:post_size_url]
          }
        },
        {
          vote_poll_options:
          {
            include:
            [
              {
                m_content: {
                  methods: [:post_size_url]
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
      include: [
        {
          m_content: {methods: [:post_size_url, :errors]}
        },
        {
          vote_poll_options: {
            methods: [:errors],
            include: [{m_content: {methods: [:post_size_url, :errors]}}]
          }
        }
      ]
    }
  end

end
