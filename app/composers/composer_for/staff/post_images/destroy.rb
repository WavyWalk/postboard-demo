class ComposerFor::Staff::PostImages::Destroy < ComposerFor::Base


  def initialize(params, controller)
    @params = params
    @controller = controller
  end


  def before_compose
    find_and_set_post_image
    find_and_set_post_node
    find_and_set_post
  end


  def find_and_set_post_image
    @post_image = ::PostImage.find(@params['id'])
  end


  def find_and_set_post_node
    #beacuse post image has file extraparam as post_node_id will be serialized as attribte upon request
    post_node_id = @params['post_node_id'] ? @params['post_node_id'] : @params['post_image']['post_node_id']
    @post_node = ::PostNode.find_by(id: post_node_id, node_id: @post_image.id, node_type: 'PostImage')
    unless @post_node
      raise ActiveRecord::RecordNotFound.new(@post_node)
    end
  end


  def find_and_set_post
    @post = @post_node.post
  end


  def compose
    Services::Post::SNodesUpdater.delete_post_node(@post, @post_node) 
    #attahes error to post_image if node can't be removed
    validate_affected_posts

    unless @post_image.valid?
      raise ActiveRecord::RecordInvalid.new(@post_image)
    end

    if can_destroy_post_image
      @post_image.destroy!
    end

    @post_node.destroy!   
  end


  def can_destroy_post_image
    post_nodes = PostNode.where(node_id: @post_image.id, node_type: 'PostImage')
    post_nodes.length < 2 ? true : false    
  end


  def validate_affected_posts
    @post.validation_service.set_attributes(:post_node_to_be_deleted).validate
    
    if errors = @post.custom_errors[:general]
      errors.each do |error|
        @post_image.add_custom_error(:general, error)
      end
    end
  
  end


  def resolve_success
    publish(:ok, @post_image)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error)
    else
      raise e
    end

  end

end
