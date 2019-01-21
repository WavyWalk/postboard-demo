class ModelValidator::MediaStoryNode < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}

  def media_story_create_scenario
    set_attributes(
      :annotation,
      :media_id,
      :media_type
    )
  end

  def update_scenario
    set_attributes(
      :annotation
    )
  end

  def media_node_changed_scenario
    set_attributes(
      :media_id,
      :media_type
    )
  end

  def annotation
    should_present and should_be_longer_than(2, "text is too short")
  end

  def media_id
    if @model.media_type != 'VideoEmbed'
      if @model.media_id.blank?
        add_error('media', 'invalid media slide')
      end
    elsif @model.media_type == 'VideoEmbed'
      @model.media.validation_service.set_scenarios(:post_create).validate
      
    else
      add_error('general', 'media is invalid')
    end
  end

  def media_type
    should_present    
    check_existence_of_media
  end

  def check_existence_of_media
    case @model.media_type
    when 'PostImage'
      unless ::PostImage.exists?(id: @model.media_id)
        add_error('media', 'invalid image')
      end
    when 'PostGif'
      unless ::PostGif.exists?(id: @model.media_id)
        add_error('media', 'invalid gif')
      end
    # when 'VideoEmbed'
    #    unless ::VideoEmbed.exists?(id: @model.media_id)
    #      add_error('media', 'invalid video embedding')
    #    end
    end
  end

end

