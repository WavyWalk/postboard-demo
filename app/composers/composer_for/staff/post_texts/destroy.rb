class ComposerFor::Staff::PostTexts::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post_text
  end

  def find_and_set_post_text
    @post_text = PostText.find(@params['id'])
  end

  def compose
    Services::Post::SNodesUpdater.delete_where_post_text_is(@post_text)    
    validate_affected_posts
    if @post_text.valid?
      @post_text.post_node.destroy!
      @post_text.destroy!
    else
      raise ActiveRecord::RecordInvalid.new(@post_text)
    end
  end

  def validate_affected_posts
    post = @post_text.post

    post.validation_service.set_scenarios(:when_post_text_is_destroyed).validate
    
    if errors = post.custom_errors[:general]
      errors.each do |error|
        @post_text.add_custom_error(:general, error)
      end
    end
  
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
