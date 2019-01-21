class ModelValidator::MediaStory < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes(
      :title,
      :media_story_nodes
    )
  end

  def update_scenario
    set_attributes(
      :title
    )
  end

  def post_create_scenario
    #assumed validated, because it's been already created
    #but it's called anyway from post/create composer
    #create_scenario
  end

  def title
    should_present and (
      should_be_longer_than(2)
    )
  end

  def media_story_nodes
    should_be_longer_than(1, 'at least two slides should be added')
  end

  def user_id
    should_present("malicious input")
  end

end

