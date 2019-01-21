class ComposerFor::TestAnswerVariants::ContentImages::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_content_image_id
    find_and_set_test_answer_variant
    assign_attributes
    validate
  end

  def set_content_image_id
    @content_image_id = @params['id'] 
  end

  def find_and_set_test_answer_variant
    @test_answer_variant = TestAnswerVariant.where(id: @params['test_answer_variant_id']).first
    unless @test_answer_variant
      fail_immediately(:variant_does_not_exist)
    end
  end

  def assign_attributes
    @test_answer_variant.content_id = @content_image_id
    @test_answer_variant.content_type = 'PostImage'
  end

  def validate
    @test_answer_variant.validation_service.set_attributes(:content_id).validate
  end

  def compose
    @test_answer_variant.save
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_answer_variant_content_updated(@test_answer_variant)
  end

  def resolve_success
    publish :ok, @test_answer_variant
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid 
      publish(:validation_error, @test_answer_variant)
    when :question_does_not_exist
      post_image = PostImage.new
      post_image.errors.add(:general, 'non existant')
      publish(:variant_does_not_exist, post_image)
    else
      raise e
    end

  end

end
