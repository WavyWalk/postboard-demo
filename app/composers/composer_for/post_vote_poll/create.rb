class ComposerFor::PostVotePoll::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_vote_poll
    set_vote_poll_attributes
    assign_attributes
    build_vote_poll_options
    validate_vote_poll
    validate_vote_poll_options
  end

  def set_vote_poll
    @vote_poll = ::PostVotePoll.new
  end

  def set_vote_poll_attributes
    @vote_poll_attributes = (
      @params.require('post_vote_poll')
      .permit(
        'question', 
        'm_content_type',
        {
          'm_content' => [
            'id'
          ]
        },
        {
          'vote_poll_options' => [
            'content',
            'm_content_type',
            {
              'm_content' => [
                'id'
              ]
            }
          ]
        }
      )
    )
  end

  def assign_attributes
    @vote_poll.question = @vote_poll_attributes['question']
    @vote_poll.user_id = @controller.current_user.id
    
    if content = @vote_poll_attributes['m_content']
      @vote_poll.m_content_id = content['id'] 
      @vote_poll.m_content_type = 'PostImage'
    end
    
    @vote_poll.orphaned = true
  end

  def build_vote_poll_options
    return unless @vote_poll_attributes['vote_poll_options']
    @vote_poll_attributes['vote_poll_options'].each do |vote_poll_option_attributes|
      @vote_poll.vote_poll_options << VotePollOption.factory.build_from_attributes_for_create(vote_poll_option_attributes)
    end
  end

  def validate_vote_poll
    @vote_poll.validation_service
      .set_scenarios(:create)
      .validate
  end

  def validate_vote_poll_options
    @vote_poll.vote_poll_options.each do |vp_o|
      vp_o.validation_service
        .set_scenarios(:create)
        .validate
    end
  end

  def compose
    @vote_poll.save!
    #serialize_options_and_save!
  end
  #TODO: remove - should be serialized only on post
  # def serialize_options_and_save!
  #   @vote_poll.updater_service.serialize_vote_poll_options_and_assign_them_to_s_options
  #   @vote_poll.save!
  # end

  def resolve_success
    publish(:ok, @vote_poll)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @vote_poll)
    else
      raise e
    end

  end

end
