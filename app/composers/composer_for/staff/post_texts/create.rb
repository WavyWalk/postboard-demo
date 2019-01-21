class ComposerFor::Staff::PostTexts::Create < ComposerFor::Base


  def initialize(params, controller)
    @params = params
    @controller = controller
  end


  def before_compose
    permit_attributes
    initialize_post_text
    assign_attributes
    initialize_post_node
    validate_post_text
    find_and_set_post
  end


  def permit_attributes
    @permitted_attributes = @params
      .require('post_text')
      .permit('content')
  end


  def initialize_post_text
    @post_text = PostText.new
  end


  def assign_attributes
    content = Services::PostTextSanitizer.sanitize_post_text_content(@permitted_attributes['content'])
    @post_text.content = content
  end


  def initialize_post_node
    @post_node = PostNode.new
    @post_node.node = @post_text
    @post_node.post_id = @params['post_id']
  end


  def validate_post_text
    @post_text.validation_service.set_attributes(:content).validate
  end

  def find_and_set_post
    @post = Post.find(@params['post_id'])
  end


  def compose
    #saves post_text as well
    @post_node.save!
    update_s_nodes_on_parent_posts
  end


  def update_s_nodes_on_parent_posts
    errors = Services::Post::SNodesUpdater.insert_new_post_node_at_position(@post, @post_node, @params['position'])
    if errors
      errors.each do |error|
        @post_node.node.errors.add(:general, error)  
      end
      raise ActiveRecord::RecordInvalid.new(@post_node)
    end
  end


  def resolve_success
    publish(:ok, @post_node)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_node)
    else
      raise e
    end

  end

end
