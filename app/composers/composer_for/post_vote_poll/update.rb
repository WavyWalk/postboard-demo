class ComposerFor::PostVotePoll::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    find_and_set_post_vote_poll
    assign_attributes
    validate
  end


  def permit_attributes
    @permitted_attributes = @params.require('post_vote_poll')
      .permit(
        'question'
      )
  end

  def find_and_set_post_vote_poll
    @post_vote_poll = PostVotePoll.find(@params['id'])
  end

  def assign_attributes
    @post_vote_poll.question = @permitted_attributes['question']
  end

  def validate
    @post_vote_poll.validation_service.set_scenarios(:update).validate
  end

  def compose
    @post_vote_poll.save!
    Services::Post::SNodesUpdater::PostVotePolls.update_when_post_vote_poll_updated(@post_vote_poll)
  end

  def resolve_success
    publish(:ok, @post_vote_poll)
  end

  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_vote_poll)
    else
      raise e
    end

  end

end
