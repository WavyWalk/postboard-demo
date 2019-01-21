class ModelValidator::PostTag < ModelValidator::Base







  def regular_create_scenario
    set_attributes :name
  end


  def staff_create_scenario
    set_attributes :name
    @by_staff = true
  end




  def name

    if @by_staff
      
      should_not_contain_symbols

      should_be_longer_than(1)

    else

      should_not_contain_symbols

      should_not_be_in(target_array: PostTag::SPECIAL_TAGS)

      should_be_longer_than(1)

    end

  end




end
