class ModelValidator::PostImage < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def assignemnt_to_post_node_scenario
    set_attributes :id
  end

  def create_scenario
    set_attributes :alt_text, :source_name
  end

  def post_create_scenario
    set_attributes :id
  end

  def staff_update_scenario
    set_attributes :id
  end

  def id
    should_present
  end

  def alt_text
    if @model.alt_text.blank?
      add_error(:alt_text, "should be filled")
    end
  end

  def source_name
    # source_name_blank = @model.source_name.blank? 
    # source_link_blank = @model.source_link.blank? 

    # if source_name_blank && !source_link_blank
    #   add_error(:source_link, "should be filled")
    # end

    # if source_link_blank && !source_name_blank
    #   add_error(:source_name, "should be filled")
    # end
  end

end
