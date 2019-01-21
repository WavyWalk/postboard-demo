class ComposerFor::VotePollOptions::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    find_and_set_vote_poll_option_being_updated
    assign_attributes
    validate
  end


  def permit_attributes
    @permitted_attributes = @params.require('vote_poll_option')
      .permit(
        'content'
      ) 
  end

  def find_and_set_vote_poll_option_being_updated
    vote_poll_option_id = @params['id']    
    @vote_poll_option = VotePollOption.find(vote_poll_option_id)
  end

  def assign_attributes
    @vote_poll_option.content = @permitted_attributes['content']
  end

  def validate
    @vote_poll_option.validation_service.set_scenarios(:create).validate
  end

  def compose
    @vote_poll_option.save!
    update_related_post_s_nodes
  end

  def update_related_post_s_nodes
    Services::Post::SNodesUpdater::PostVotePolls.update_when_vote_poll_option_updated(@vote_poll_option)
  end

  def resolve_success
    publish(:ok, @vote_poll_option)
  end

  def resolve_fail(e)
    
    case e
    when  ActiveRecord::RecordInvalid
      publish(:validation_error, @vote_poll_option)
    else
      raise e
    end

  end

end
