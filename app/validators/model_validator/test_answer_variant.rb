class ModelValidator::TestAnswerVariant < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def for_test_create_scenario
    set_attributes :text, :content_id, :answer_type, :correct, :on_select_message
  end

  def personality_test_create_scenario
    set_attributes :text, :content_id
  end

  def personality_test_destroy_scenario
    set_attributes :variants_on_question
  end

  def personality_test_create_separate_scenario
    set_attributes :text, :content_id, 
        :personality_scales, :test_question_id
  end

  def destroy_scenario
    set_attributes :question_should_have_gt_one_variant
  end

  def regular_update_scenario
    set_attributes :text, :correct, :on_select_message
  end

  def question_should_have_gt_one_variant
    if @model.test_question.test_answer_variants.size < 3
      add_error(:general, 'question must have at least two variants')
    end    
  end

  def test_question_id
    should_present    
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

  def answer_type
    #not implemented
  end

  def on_select_message
    #not implemented
  end

  def correct
    unless @model.correct == true || @model.correct == false || @model.correct == nil
      add_error(:correct, 'invalid value')
    end
  end

  def personality_scales
    personalities = ::P_T_Personality.joins(post_test: [:test_questions]).where('test_questions.id = ?', @model.test_question_id)
    personality_scales = @model.personality_scales
    if personalities.map(&:id).sort != personality_scales.map(&:p_t_personality_id).sort
      add_error(:general, 'scales invalid')
    end    
    personality_scales.each do |personality_scale|
      personality_scale.validation_service.set_scenarios(:personality_test_create).validate
    end
  end

  def variants_on_question
    if @model.test_question.test_answer_variants.size < 1
      add_error(:general, 'question must have at least one variant')
    end
  end

end

