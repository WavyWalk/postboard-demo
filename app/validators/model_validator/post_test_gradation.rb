class ModelValidator::PostTestGradation < ModelValidator::Base
  # def #{attribute_name}_scenario ; def #{attribute_name}
  def set_post_test(post_test)
    @post_test = post_test
    self
  end

  def post_test
    if @model.post_test_id
      ::PostTest.where(id: @model.post_test_id).first
    else
      @post_test
    end
  end

  def for_test_create_scenario
    set_attributes :from, :to, :message, :content_id
  end

  def regular_update_scenario
    set_attributes :from, :to, :message
  end

  def post_test_id
    should_present
    post_test = ::PostTest.where(id: @model.post_test_id).first

    unless post_test
      add_error(:general, 'test does not exist')
    end

  end

  def from
    should_present

    test_value = @model.from.to_i

    if test_value < 0
      add_error(:from, 'invalid')
    end

    if test_value > post_test.test_questions.size 
      add_error(:from, 'invalid')
    end

    if test_value > @model.to.to_i
      add_error(:from, 'can\'t be greater that to')
    end

  end

  def to
    should_present

    test_value = @model.to.to_i rescue -1

    if test_value < 0
      add_error(:to, 'invalid')
    end

    if test_value > post_test.test_questions.size 
      add_error(:to, 'invalid')
    end

    if test_value < @model.from.to_i
      add_error(:to, "can't be lesser than from value")
    end

  end

  def message
    should_present
  end

  def content_id
    if @model.content_id
      unless @model.content_type == 'PostImage'
        add_error(:general, 'invalid')
      else
        post_image = PostImage.where(id: @model.content_id).first
        unless post_image
          add_error(:content, 'invalid image')
        end
      end
    end
  end


end

