class ComposerFor::PostTestGradations::ContentImages::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_post_test_gradation_id
    find_and_set_post_test_gradation
    assign_attributes
    validate
  end

  def set_post_test_gradation_id
    @post_test_gradation_id = @params['id'] 
  end

  def find_and_set_post_test_gradation
    @post_test_gradation = PostTestGradation.where(id: @params['post_test_gradation_id']).first
    unless @post_test_gradation
      fail_immediately(:gradation_does_not_exist)
    end
  end

  def assign_attributes
    @post_test_gradation.content_id = @post_test_gradation_id
    @post_test_gradation.content_type = 'PostImage'
  end

  def validate
    @post_test_gradation.validation_service.set_attributes(:content_id).validate
  end

  def compose
    @post_test_gradation.save
  end

  def resolve_success
    publish :ok, @post_test_gradation
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid 
      publish(:validation_error, @post_test_gradation)
    when :question_does_not_exist
      post_image = PostImage.new
      post_image.errors.add(:general, 'non existant')
      publish(:gradation_does_not_exist, post_image)
    else
      raise e
    end

  end

end
