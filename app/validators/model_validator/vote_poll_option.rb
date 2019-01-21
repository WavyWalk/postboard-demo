class ModelValidator::VotePollOption < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :content
  end

  def content
    should_not_be_empty
  end

end

