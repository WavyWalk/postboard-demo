class AsJsonSerializer::Posts::DiscussionMessages::Create

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
          discussion_message_karma:
          {
            root: true
          }
        }
      ]
    }
  end

  def error_options
    {
      methods:
      [
        :errors
      ]
    }
  end

end
