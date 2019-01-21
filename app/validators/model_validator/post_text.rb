class ModelValidator::PostText < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :content
  end

  def post_create_scenario
    set_attributes :content
  end

  def staff_update_scenario
    set_attributes :content
    self
  end

  def content
    should_present
    #TODO: 
    #should sanitize html
  end

end
