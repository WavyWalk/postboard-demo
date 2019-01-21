class ModelValidator::PostVotePoll < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :question, :vote_poll_options, :orphaned, :user_id
  end

  def update_scenario
    set_attributes :question
  end

  def post_create_scenario
    set_attributes :id
  end

  def question
    should_present
  end

  def vote_poll_option_to_be_deleted
    if @model.vote_poll_options.length < 3
      add_error(:general, "no less than 2 options allowed")
    end
  end

  def vote_poll_options
    if @model.vote_poll_options.length < 2
      add_error(:general, "no less than 2 options allowed")
    end
  end

  def user_id
    should_present
  end

  def orphaned
    should_eq_true
  end

  def id
    should_present
  end

end

