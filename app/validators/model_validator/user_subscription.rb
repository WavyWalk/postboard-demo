class ModelValidator::UserSubscription < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :user_id, :to_user_id
  end

  def user_id
    should_present
    should_be_signed_integer
    unless User.exists?(m.send(c_a))
      add_error c_a, "non_existent_to_user"
    end
  end

  def to_user_id
    should_present and
    should_be_signed_integer and
    unless User.exists?(m.senf(c_a))
      add_error c_a, "non_existent_to_user"
    end
  end


end
