class ComposerFor::VotePollOptions::Destroy < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_vote_poll_option
    set_post_vote_poll
    validate_post_vote_poll
  end


  def set_vote_poll_option
    @vote_poll_option = VotePollOption.find(@params['id'])
  end

  def set_post_vote_poll
    @post_vote_poll = @vote_poll_option.post_vote_poll
  end

  def validate_post_vote_poll
    @post_vote_poll.validation_service.set_attributes(:vote_poll_option_to_be_deleted).validate
  end

  def compose
    if @post_vote_poll.has_custom_errors?
      @post_vote_poll.custom_errors[:general].each do |error|
        @vote_poll_option.add_custom_error(:general, error)
      end
      @vote_poll_option.validate
      raise ActiveRecord::RecordInvalid.new(@post_vote_poll)
    end    


    @vote_poll_option.destroy!

    update_s_nodes_on_related_posts
  end

  def update_s_nodes_on_related_posts
    posts = Post.joins(:post_nodes)
      .where(
        'post_nodes.node_type = ? and post_nodes.node_id = ?',
        'PostVotePoll', @post_vote_poll.id
      )

    posts.each do |post|
      ::Services::Post::SNodesUpdater::PostVotePolls.update_when_vote_poll_option_destroyed(post, @post_vote_poll.id, @vote_poll_option.id)  
    end
  end


  def resolve_success
    publish(:ok, @vote_poll_option)
  end

  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @vote_poll_option)
    else
      raise e
    end

  end

end
