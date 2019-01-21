class ComposerFor::Staff::VideoEmbeds::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_video_embed
    find_and_set_post_node
    find_and_set_post
  end

  def find_and_set_video_embed
    @video_embed = ::VideoEmbed.find(@params['id'])
  end


  def find_and_set_post_node
    post_node_id = @params['post_node_id'] 
    @post_node = ::PostNode.find_by(
      id: post_node_id, 
      node_id: @video_embed.id, 
      node_type: 'VideoEmbed'
    )
    unless @post_node
      raise ActiveRecord::RecordNotFound.new(@post_node)
    end
  end


  def find_and_set_post
    @post = @post_node.post
  end


  def compose
    Services::Post::SNodesUpdater.delete_post_node(@post, @post_node) 
    #attahes error to video_embed if node can't be removed
    validate_affected_posts

    unless @video_embed.valid?
      raise ActiveRecord::RecordInvalid.new(@video_embed)
    end

    if can_destroy_video_embed
      @video_embed.destroy!
    end

    @post_node.destroy!   
  end


  def validate_affected_posts
    @post.validation_service.set_attributes(:post_node_to_be_deleted).validate
    
    if errors = @post.custom_errors[:general]
      errors.each do |error|
        @video_embed.add_custom_error(:general, error)
      end
    end
  
  end


  def can_destroy_video_embed
    post_nodes = PostNode.where(node_id: @video_embed.id, node_type: 'VideoEmbed')
    post_nodes.length < 2 ? true : false    
  end

  def resolve_success
    publish(:ok, @video_embed)  
  end

  def resolve_fail(e)
    
    case e
    when :validation_error
      publish(:validation_error, @video_embed)
    else
      raise e
    end

  end

end
