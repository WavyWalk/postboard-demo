class Services::TestAnswerVariant::Updater

  def initialize(owner)
    @owner = owner
  end

  def regular_update(params)
    @owner.text = params['text']
    @owner.correct = params['correct']
    @owner.on_select_message = params['on_select_message']
    self
  end

  def get_result
    @owner
  end

end