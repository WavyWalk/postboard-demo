class ModelValidator::TestQuestion < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def for_test_create_scenario
    set_attributes :text, :content_id, :question_type, :on_answered_msg, :test_answer_variants, :on_answered_m_content_id
  end

  def personality_test_create_scenario
    set_attributes :text, :content_id, :test_answer_variants_personality_test_length 
  end

  def destroy_scenario
    set_attributes :test_should_have_gt_one_questions
  end

  def personality_test_create_separate_scenario
    set_attributes :text, :content_id, 
        :test_answer_variants_personality_test_length,
        :post_test_id,
        :personality_scales_on_test_answer_variants,
        :validate_test_answer_variants
  end

  def test_should_have_gt_one_questions
    if @model.post_test.test_questions.size < 3
      add_error(:general, 'test must have at least 2 questions')
    end
  end

  def post_test_id
    should_present
    # post_test = ::PostTest.find(@model.post_test_id)
    # unless post_test.is_personality
    #   add_error(:general, 'wrong post test type')
    # end
  end

  def text
    should_present
  end

  def content_id
    if @model.content_id
      unless @model.content_type == 'PostImage'
        add_error(:general, 'invalid')
      else
        post_image = ::PostImage.where(id: @model.content_id).first
        unless post_image
          add_error(:content, 'invalid image')
        end
      end
    end
  end

  def on_answered_m_content_id
    if @model.on_answered_m_content
      if @model.on_answered_m_content_type.blank?
        add_error(:general, 'on answered media is invalid')
      else
        child_model = nil
        
        case @model.on_answered_m_content_type
        when 'PostImage'
          child_model = PostImage
        when 'PostGif'
          child_model = PostGif
        else
          child_model = nil
        end

        if child_model == nil
          add_error(:on_answered_m_content, 'invalid')
        else
          child_model = child_model.find(@model.on_answered_m_content_id)
          unless child_model
            add_error(:on_answered_m_content, 'invalid')
          end
        end
      end
    end
  end

  def question_type
    #not implemented
  end

  def on_answered_msg
    #not implemented
  end

  def test_answer_variants
    unless @model.test_answer_variants.length > 1
      add_error(:general, 'at least 2 variants must be added')
    else
      @model.test_answer_variants.each do |variant|
        variant.validation_service.set_scenarios(:for_test_create).validate 
      end
    end
  end

  def test_answer_variants_personality_test_length
    if @model.test_answer_variants.length < 1
      add_error(:general, 'at least one variant should be added')
    end
  end

  def validate_test_answer_variants
    @model.test_answer_variants.each do |test_answer_variant|
      test_answer_variant.validation_service.set_scenarios(:personality_test_create).validate
    end
  end

  def personality_scales_on_test_answer_variants
    personalities = ::P_T_Personality.where(post_test_id: @model.post_test_id)
    personalities_ids = personalities.map(&:id).sort
    @model.test_answer_variants.each do |test_answer_variant|
      personality_scales = test_answer_variant.personality_scales
      if personality_scales.size != personalities.size
        test_answer_variant.add_custom_error(:general, 'wrong scales')        
      end

      personality_scales_p_t_personalities_ids = personality_scales.map(&:p_t_personality_id).sort

      if personalities_ids != personality_scales_p_t_personalities_ids
        test_answer_variant.add_custom_error(:general, 'wrong scales')
      end

    end
  end

end

