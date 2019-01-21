class ComposerFor::Staff::PostTexts::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post_text
    permit_attributes
    assign_attributes
    validate
  end

  def find_and_set_post_text
    @post_text = PostText.find(@params['id'])
  end

  def permit_attributes
    @permitted_attributes = @params.require('post_text').permit('content')
  end

  def assign_attributes
     content = Services::PostTextSanitizer.sanitize_post_text_content(@permitted_attributes['content'])
     @post_text.content = content
  end

  def validate
    @post_text.validation_service.set_attributes(:content).validate    
  end

  def compose
    @post_text.save!
    update_s_nodes_on_parent_posts
  end

  def update_s_nodes_on_parent_posts
    Services::Post::SNodesUpdater.update_where_post_text_is(@post_text)
  end

  def resolve_success
    publish(:ok, @post_text)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_text)
    else
      raise e
    end

  end

end
