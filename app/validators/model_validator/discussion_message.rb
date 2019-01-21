class ModelValidator::DiscussionMessage < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_to_posts_discussion_scenario
    set_attributes :discussion_id, :user_id, :content
  end

  def content
    should_present
  end

  def user_id
    should_present
  end

  def discussion_id 
    should_present
  end


end
