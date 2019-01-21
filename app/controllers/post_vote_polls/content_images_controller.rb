class PostVotePolls::ContentImagesController < ApplicationController

  def update
    post_vote_poll_id = params['post_vote_poll_id']
    post_vote_poll = PostVotePoll.find(post_vote_poll_id)

    m_content_id = params['id']

    post_vote_poll.m_content_id = m_content_id
    post_vote_poll.m_content_type = 'PostImage'

    post_vote_poll.save

    image = PostImage.find(post_vote_poll.m_content_id)

    render json: image.as_json()
  end

  def destroy
    gr = PostVotePoll.find(params['post_vote_poll_id'])
    gr.m_content_id  = nil
    gr.m_content_type = nil
    gr.save
    render json: PostImage.find(params[:id]).as_json
  end

end
