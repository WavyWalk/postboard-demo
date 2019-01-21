class ModelValidator::UserCredential < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}

  def create_scenario

    set_attributes :password, :email, :name, :password_digest

  end


  def create_from_oauth_scenario
    set_attributes :name
  end


  def first_time_password
    @current_attribute = :password
    password
  end

  def first_time_email
    @current_attribute = :email
    email
  end

  def password
    #should_present if !other_attr_presents?(:email)

    should_be_longer_than(3, 'too short') if not_blank?

    should_match_confirmation('should match confirmation') if not_blank?

  end

  def email

    # if !other_attr_presents?(:password)

    #   should_present

    # end

    should_be_uniq('email has already been taken') if not_blank?

    should_be_valid_email('not valid email') if not_blank?

  end


  def name
    should_present

    should_be_longer_than(0, 'too short') if not_blank?

    should_be_uniq('name has already been taken') if not blank?
  end


  def password_digest
    should_present if other_attr_presents?(:password)
  end


end
