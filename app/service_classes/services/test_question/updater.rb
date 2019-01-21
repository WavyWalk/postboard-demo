class Services::TestQuestion::Updater

  def initialize(owner)
    @owner = owner
  end

  def regular_update(params)
    @owner.text = params['text']
    @owner.on_answered_msg = params['on_answered_msg']
    self
  end

  def personality_update(params)
    @owner.text = params['text']
    self
  end

  def get_result
    @owner
  end

end
