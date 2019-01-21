class ComposerFor::TestQuestions::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_test_question!
    #set_is_personality
    permit_attributes
    assign_attributes
    run_validations
  end

  def find_and_set_test_question!
    @test_question = TestQuestion.where(id: @params['id']).first
    unless @test_question
      fail_immediately(:question_does_not_exist)
    end
  end

  # def set_is_personality
  #   @is_personality = @test_question.post_test.is_personality
  # end

  def permit_attributes
    @permitted_attributes = @params.require('test_question')
    .permit('text', 'on_answered_msg')
  end

  def assign_attributes
    # if @is_personality
    #   @test_question.updater.personality_update(@permitted_attributes)
    # else
      @test_question.updater.regular_update(@permitted_attributes)
    # end
  end

  def run_validations
    @test_question.validation_service.set_attributes(:text).validate
  end

  def compose
    @test_question.save!
    # unless @is_personality
    #   @test_question.post_test.updater.serialize_necessary_fields_and_save_and_update_s_nodes_on_related_posts
    # end
    Services::Post::SNodesUpdater::PostTestsRelated.update_when_test_question_updated(@test_question)
  end

  def resolve_success
    publish(:ok, @test_question)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid 
      publish(:validation_error, @test_question)

    when :question_does_not_exist
      test_question = TestQuestion.new
      test_question.errors.add(:general, 'non existant')
      publish(:question_does_not_exist, test_question)
      
    else
      raise e
    end

  end

end
