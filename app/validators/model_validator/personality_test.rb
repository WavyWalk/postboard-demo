class ModelValidator::PersonalityTest < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :title, :thumbnail_id, :p_t_personalities, :check_scale_counts  
  end

  def create_final_scenario
    
  end

  def title
    should_present
  end



  def thumbnail_id
    unless @model.thumbnail_id
      add_error(:general, 'thumnail should be assigned')
    else
      post_image = ::PostImage.where(id: @model.thumbnail_id).first
      unless post_image
        add_error(:thumbnail, 'invalid thumbnail image')
      else
        # if post_image.user_id != @model.user_id
        #   add_error(:thumbnail, 'unauthorized to use this image')
        # end
      end
    end
  end

  def p_t_personalities
    if @model.p_t_personalities.size < 2
      add_error(:general, 'at least two personalities required')
    end 
  end

  def check_scale_counts
    personalities_length = @model.p_t_personalities.length
    @model.test_questions.each do |test_question|
      test_question.test_answer_variants.each do |test_answer_variant|
        if test_answer_variant.personality_scales.length != personalities_length
          add_error(:general, 'invalid personality scales')
        end
      end
    end
  end

end

