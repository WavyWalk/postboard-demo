class ComposerFor::Staff::PostVotePolls::Destroy < ComposerFor::Base


  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    find_and_set_post_vote_poll
    find_and_set_post_node
    find_and_set_post
  end

  def find_and_set_post_vote_poll
    @post_vote_poll = ::PostVotePoll.find(@params['id'])
  end


  def find_and_set_post_node
    post_node_id = @params['post_node_id'] 
    @post_node = ::PostNode.find_by(
      id: post_node_id, 
      node_id: @post_vote_poll.id, 
      node_type: 'PostVotePoll'
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
    #attahes error to post_vote_poll if node can't be removed
    validate_affected_posts

    unless @post_vote_poll.valid?
      raise ActiveRecord::RecordInvalid.new(@post_vote_poll)
    end

    if can_destroy_post_vote_poll
      @post_vote_poll.destroy!
    end

    @post_node.destroy!   
  end


  def validate_affected_posts
    @post.validation_service.set_attributes(:post_node_to_be_deleted).validate
    
    if errors = @post.custom_errors[:general]
      errors.each do |error|
        @post_vote_poll.add_custom_error(:general, error)
      end
    end
  
  end


  def can_destroy_post_vote_poll
    post_nodes = PostNode.where(node_id: @post_vote_poll.id, node_type: 'PostVotePoll')
    post_nodes.length < 2 ? true : false    
  end

  def resolve_success
    publish(:ok, @post_vote_poll)  
  end

  def resolve_fail(e)
    
    case e
    when :validation_error
      publish(:validation_error, @post_vote_poll)
    else
      raise e
    end

  end

end
