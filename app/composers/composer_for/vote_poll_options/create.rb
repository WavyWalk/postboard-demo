class ComposerFor::VotePollOptions::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    build_and_set_new_vote_poll_option
    assign_attributes
    validate
  end

  def permit_attributes
    @permitted_attributes = @params.require('vote_poll_option')
    .permit(
      'content',
      'm_content_type',
      'm_content' => [
        'id'
      ]
    )    
  end

  def build_and_set_new_vote_poll_option
    @vote_poll_option = VotePollOption.new
  end

  def assign_attributes
    @vote_poll_option.post_vote_poll_id = @params['post_vote_poll_id']
    @vote_poll_option.content = @permitted_attributes['content']
    @vote_poll_option.m_content_type = @permitted_attributes['m_content_type']
    if x = @permitted_attributes['m_content']    
      @vote_poll_option.m_content_id = x['id'] 
    end
    @vote_poll_option.count = 0
  end

  def validate
    @vote_poll_option.validation_service.set_scenarios(:create).validate
  end

  def compose
    @vote_poll_option.save!

    update_related_post_s_nodes
  end


  def update_related_post_s_nodes
    Services::Post::SNodesUpdater::PostVotePolls.update_when_vote_poll_option_created(@vote_poll_option)
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
