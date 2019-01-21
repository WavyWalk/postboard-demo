class ModelValidator::VideoEmbed < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}

  def post_create_scenario
    set_attributes(:link, :provider)
  end

  def create
    post_create_scenario
  end

  def staff_update_scenario
    set_attributes(:link, :provider)
  end

  def link
    should_regex_match_one_of([::VideoEmbed::YOUTUBE_REGEX], 'invalid link')
  end

  def provider
    should_present and should_be_in(target_array: ::VideoEmbed::ALLOWED_PROVIDER_NAMES)
  end

end

