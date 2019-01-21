class Permissions::VotePollOptionRules < Permissions::Base

  def create(post_vote_poll_id:)
    if (@current_user && current_user_is_owner_of_vote_poll(post_vote_poll_id)) || current_user_is_staff
      return true
    else
      return false
    end
  end

  def update(vote_poll_option_id:)

    post_vote_poll_id = PostVotePoll.joins(:vote_poll_options).where(vote_poll_options: {id: vote_poll_option_id}).first.id
    
    if (@current_user && current_user_is_owner_of_vote_poll(post_vote_poll_id)) || current_user_is_staff
      return true
    else
      return false
    end
  
  end

  def current_user_is_owner_of_vote_poll(post_vote_poll_id)
    post_vote_poll = PostVotePoll.where(id: post_vote_poll_id).first
    if post_vote_poll.user_id == @current_user.id
      return true
    else
      return false
    end
  end

  def current_user_is_staff
    if @current_user.role_service.has_roles?('staff')
      return true
    else
      return false
    end
  end

end
