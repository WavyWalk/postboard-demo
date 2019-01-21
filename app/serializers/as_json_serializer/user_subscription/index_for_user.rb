class AsJsonSerializer::UserSubscription::IndexForUser
  
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
        :usub_with_current_user, 
        :user_denormalized_stat, 
        :user_karma
      ]
    }
  end

  def error_options
    {

    }
  end

end
