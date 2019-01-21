require 'json'

class ModelValidator::PostGif < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def assignemnt_to_post_node_scenario
    set_attributes :id
  end

  def post_create_scenario
    set_attributes :id
  end

  def when_subtitles_added_scenario
    set_attributes :id, :subtitles
  end

  def staff_update
    set_attributes :id
  end

  def id
    should_present
  end

  def subtitles
    jsoned_subtitles = should_be_json_parsable
    
    unless jsoned_subtitles.is_a?(Array)
      add_error(c_a, 'invalid')
      return
    end

    if jsoned_subtitles.length > 25
      add_error(c_a, 'no more than 25 subtitles can be added')
      return
    end

    jsoned_subtitles.each_with_index do |subtitle, index|
      validate_individiual_subtitle(subtitle, index)
    end
  end

  ######
  def should_be_json_parsable
    JSON.parse(@model.subtitles)
  rescue Exception => e
    add_error(c_a, 'invalid')
  end

  def validate_individiual_subtitle(subtitle, index)
    unless subtitle['content'].is_a?(String) && subtitle['content'].length > 0
      add_error(c_a, "#{index + 1}: content should contain some text")
    end

    unless (subtitle['from'].is_a?(Integer) || subtitle['from'].is_a?(Float)) && subtitle['from'] >= 0
      add_error(c_a, "#{index + 1}: from time should be valid and bigger than 0")
    end

    unless (subtitle['to'].is_a?(Integer) || subtitle['to'].is_a?(Float))
      add_error(c_a, "#{index + 1}: from time should be valid numeric value")
    end

    if subtitle['from'] >= subtitle['to']
      add_error(c_a, "#{index + 1}: there should be some time between from and to values")
    end

    unless !keys_are_ok_in_subtitle(subtitle, index)
      add_error(c_a, "#{index +  1}: unexpected input")
    end
  end

  def keys_are_ok_in_subtitle(subtitle, index)
    if subtitle.keys.length > 4
      true
    end

    if !(subtitle.keys - ['from', 'to', 'style', 'content']).empty?
      true
    end

  end

end
