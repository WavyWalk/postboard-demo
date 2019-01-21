class VotePollOptionsController < ApplicationController 

  def create
    permissions = build_permissions VotePollOption

    authorize! permissions.create(post_vote_poll_id: params['post_vote_poll_id'])

    cmpsr = ComposerFor::VotePollOptions::Create.new(params, self)

    cmpsr.when(:ok) do |vote_poll_option|
      render json: vote_poll_option.as_json(include: [{m_content: {methods: [:post_size_url]}}])
    end

    cmpsr.when(:validation_error) do |vote_poll_option|
      render json: vote_poll_option.as_json(methods: [:errors], include: [{m_content: {methods: [:post_size_url, :errors]}}])
    end

    cmpsr.run 
  end

  def update

    permissions = build_permissions VotePollOption

    authorize! permissions.update(vote_poll_option_id: params['id'])

    cmpsr = ComposerFor::VotePollOptions::Update.new(params, self)

    cmpsr.when(:ok) do |vote_poll_option|
      render json: vote_poll_option.as_json(include: [:m_content])
    end

    cmpsr.when(:validation_error) do |vote_poll_option|
      render json: vote_poll_option.as_json(methods: [:errors], include: [{m_content: {methods: [:post_size_url, :errors]}}])
    end

    cmpsr.run
    
  end

  def destroy
    
    permissions = build_permissions VotePollOption

    authorize! permissions.update(vote_poll_option_id: params['id'])

    cmpsr = ComposerFor::VotePollOptions::Destroy.new(params, self)

    cmpsr.when(:ok) do |vote_poll_option|
      render json: vote_poll_option.as_json
    end

    cmpsr.when(:validation_error) do |vote_poll_option|
      render json: vote_poll_option.as_json(methods: [:errors])
    end

    cmpsr.run

  end

end
