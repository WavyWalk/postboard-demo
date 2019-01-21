class ModelValidator::P_T_Personality < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def personality_test_create_scenario
    set_attributes(:title, :media_id)    
  end

  def create_scenario
    set_attributes(:title, :media_id, :post_test_id)
  end

  def update_scenario
    set_attributes(:title)
  end

  def medias_update_scenario
    set_attributes(:media_id)
  end

  def destroy_scenario
    set_attributes(:post_test_personalities_count)
  end

  def post_test_personalities_count
    personalities = @model.post_test.p_t_personalities
    if personalities.size < 3
      add_error(:general, "too few personalities, can't delete")
    end
  end

  def title
    should_present
    if @model.title.class == String
      if @model.title.length < 1
        add_error(:title, "type something in")
      end
    end
  end



  def media_id
    
    check_existence_of_media

  end  

  def post_test_id
    post_test = ::PostTest.find( @model.post_test_id )
    unless post_test.is_personality
      add_error('general', 'unpermitted')
    end
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
    when 'VideoEmbed'
       unless ::VideoEmbed.exists?(id: @model.media_id)
         add_error('media', 'invalid video embedding')
       end
    else
      add_error('media', 'is not set')
    end
  end

end

