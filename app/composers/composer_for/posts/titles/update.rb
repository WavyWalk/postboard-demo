class ComposerFor::Posts::Titles::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post
    permit_attributes
    assign_attributes
    validate
  end

  def find_and_set_post
    @post = Post.find(@params['id'])
  end

  def permit_attributes
    @permit_attributes = @params
      .require('post')
      .permit('title')
  end

  def assign_attributes
    @post.title = @permit_attributes['title']
  end

  def validate
    @post.validation_service.set_attributes(:title).validate
  end

  def compose
    @post.save!    
  end

  def resolve_success
    publish(:ok, @post)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post)
    else
      raise e
    end

  end

end
