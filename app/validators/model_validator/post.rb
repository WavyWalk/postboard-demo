class ModelValidator::Post < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}



  def create_scenario

    set_attributes :title, :post_nodes, :post_type

  end

  def staff_update_scenario

    set_attributes :title, :post_type, :post_nodes

  end

  def when_post_text_is_destroyed_scenario
    set_attributes :post_node_to_be_deleted
  end


  def title

    should_present and should_be_longer_than(2)

  end


  def post_type
    if !@model.post_type
      add_error(:post_type, 'should be assigned')
    end
  end


  def post_nodes

    if @model.post_nodes.length < 1
      add_error(:general, 'at least one element should be added')
    end

  end

  def post_node_to_be_deleted
    if (@model.post_nodes.length - 1) < 1
      add_error(:general, "can't be less than 1 nodes")
    end
  end




end
