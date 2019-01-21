class ComposerFor::PersonalityTests::New < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    initialize_post_test_as_pesonality_test
  end

  def initialize_and_set_post_test_as_pesonality_test
    post_test = ::PostTest.new
    post_test.is_personality = true
    post_test.user_id = @controller.current_user.id
    @post_test = post_test
  end

  def compose
    @post_test.save!
  end

  def resolve_success
    publish(:ok, @post_test)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid  
      publish :validation_error, @post_test
    else
      raise e
    end

  end

end
