class ModelValidator::PostTest < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def create_scenario
    set_attributes :title, :thumbnail_id, :test_questions, :post_test_gradations
  end

  def post_create_scenario
    set_attributes :id
  end

  def id
    should_present
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

  def test_questions

    if @model.test_questions.empty?
      add_error(:general, 'at least on question should present')
    end
    @model.test_questions.each do |question|
      question.validation_service.set_scenarios(:for_test_create).validate
    end
    
  end

  def post_test_gradations
    
    @model.post_test_gradations.each do |gradation|
      gradation.validation_service.set_scenarios(:for_test_create).set_post_test(@model).validate
    end
  end

end

