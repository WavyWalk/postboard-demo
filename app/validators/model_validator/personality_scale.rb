class ModelValidator::PersonalityScale < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def personality_test_create_scenario
    set_attributes(:scale)
  end

  def scale
    scale = @model.scale

    unless scale
      add_error(:scale, "invalid")
      return       
    end 

    scale = scale.to_int
    if scale < 0 || scale > 10
      add_error(:scale, 'invalid input')
    end

    @model.scale = scale
  end

end

