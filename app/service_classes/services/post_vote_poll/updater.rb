class Services::PostVotePoll::Updater

  def initialize(owner)
    @owner = owner
  end

  def serialize_vote_poll_options_and_assign_them_to_s_options
    options = @owner.vote_poll_options
    @owner.s_options = options.as_json(include: {m_content: {methods: [:post_size_url]}}).to_json
    if @owner.m_content
      @owner.s_m_content = @owner.m_content.as_json(methods: [:post_size_url]).to_json
    end
  end

  def update_when_added_to_post(attributes)
    if @owner.orphaned != false
      @owner.orphaned = false
      @owner.save
    else
      @owner
    end
  end

end