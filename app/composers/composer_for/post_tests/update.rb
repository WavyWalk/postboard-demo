class ComposerFor::PostTests::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end


  def before_compose
    set_post_test
    permit_attributes
    assign_attributes
  end


  def set_post_test
    @post_test = ::PostTest.find(@params['id'])
  end


  def permit_attributes
    @permitted_attributes = @params.require(:post_test).permit(:title)
  end


  def assign_attributes
    @post_test.title = @permitted_attributes['title']    
  end


  def compose
    @post_test.save!    
    ::Services::Post::SNodesUpdater::PostTestsRelated.update_when_post_test_updated(@post_test)
  end

  def resolve_success
    publish(:ok, @post_test)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_test)
    else
      raise e
    end

  end

end
