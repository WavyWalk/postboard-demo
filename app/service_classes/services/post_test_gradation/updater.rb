class Services::PostTestGradation::Updater

  def initialize(owner)
    @owner = owner
  end

  def regular_update(params)
    @owner.text = params['from']
    @owner.correct = params['to']
    @owner.on_select_message = params['message']
    self
  end

  def get_result
    @owner
  end

end