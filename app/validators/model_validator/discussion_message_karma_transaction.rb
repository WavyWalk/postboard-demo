class ModelValidator::DiscussionMessageKarmaTransaction < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :amount, :user_id  
  end

  def user_id
    should_present
  end

  def amount
    should_be_signed_integer
    should_not_be_zero
  end


end

