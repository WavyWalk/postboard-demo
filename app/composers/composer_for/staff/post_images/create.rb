class ComposerFor::Staff::PostImages::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post
  end

  def find_and_set_post
    #expected as form, so extra params post_image etc are passed as attributes
    post_id = @params['post_id'] ? @params['post_id'] : @params['post_image']['post_id']
    @post = Post.find(post_id)
  end


  def compose
    cmpsr = initialize_image_create_cmpsr

    cmpsr.when(:ok) do |post_image|
      @post_image = post_image
      initialize_post_node
      @post_node.save!
      update_s_nodes_on_parent_posts
      publish(:ok, @post_node)
    end

    cmpsr.when(:validation_error) do |post_image|
      @post_image = post_image
      initialize_post_node
      raise ActiveRecord::RecordInvalid.new(@post_node)
    end

    cmpsr.run
  end


  def initialize_image_create_cmpsr
    post_image = ::PostImage.new
    ComposerFor::PostImage::Create.new(post_image, @params, @controller)
  end


  def initialize_post_node
    @post_node = PostNode.new
    @post_node.node = @post_image
    @post_node.post_id = @post.id
  end

  def update_s_nodes_on_parent_posts
    errors = Services::Post::SNodesUpdater.insert_new_post_node_at_position(
      @post, @post_node, @params['post_image']['position'].to_i
    )
    if errors
      errors.each do |error|
        @post_node.node.errors.add(:general, error)  
      end
      raise ActiveRecord::RecordInvalid.new(@post_node)
    end
  end

  #success will be called on ok
  def resolve_success
    nil
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
