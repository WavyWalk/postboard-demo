class PostVotePollsController < ApplicationController

  def create
        
    premission_rules = build_permissions PostVotePoll

    authorize! premission_rules.create

    cmpsr = ComposerFor::PostVotePoll::Create.new(params, self)

    cmpsr.when(:ok) do |post_vote_poll|
      
      render json: AsJsonSerializer::PostVotePoll::Create.new(post_vote_poll).success
    end

    cmpsr.when(:validation_error) do |post_vote_poll|
      
      render json: AsJsonSerializer::PostVotePoll::Create.new(post_vote_poll).error
    end

    cmpsr.run
  end

  def update

    premission_rules = build_permissions PostVotePoll

    authorize! premission_rules.update(post_vote_poll_id: params[:id])

    cmpsr = ComposerFor::PostVotePoll::Update.new(params, self)

    cmpsr.when(:ok) do |post_vote_poll|
      render json: post_vote_poll.as_json
    end

    cmpsr.when(:validation_error) do |post_vote_poll|
      render json: post_vote_poll.as_json(methods: [:errors])
    end

    cmpsr.run

  end


  def get_counts

    id = params[:id]

    options = VotePollOption.where(post_vote_poll_id: id)

    render json: options.as_json
    
  end

  def show
    id = params[:id]
    
    post_vote_poll = PostVotePoll.find(id)

    render json: AsJsonSerializer::PostVotePoll::Create.new(post_vote_poll).success
  end

end
