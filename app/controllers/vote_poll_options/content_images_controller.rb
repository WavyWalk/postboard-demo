class VotePollOptions::ContentImagesController < ApplicationController

  def update
    vote_poll_option_id = params['vote_poll_option_id']
    post_vote_poll = VotePollOption.find(vote_poll_option_id)

    m_content_id = params['id']

    post_vote_poll.m_content_id = m_content_id
    post_vote_poll.m_content_type = 'PostImage'

    post_vote_poll.save

    image = PostImage.find(post_vote_poll.m_content_id)

    render json: image.as_json(methods: [:post_size_url])
  end

  def destroy
    vpo = VotePollOption.find(params['vote_poll_option_id'])
    vpo.m_content_id  = nil
    vpo.m_content_type = nil
    vpo.save
    render json: PostImage.find(params['id']).as_json
  end

end
