class AsJsonSerializer::Users::Avatars::Update
  
  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end
  
  def success
    @model.s_avatar
  end

  def error
    value_to_return = {}
    errors = @model.errors['avatar']
    value_to_return['errors'] = {'avatar' => errors}
    value_to_return
  end


end
