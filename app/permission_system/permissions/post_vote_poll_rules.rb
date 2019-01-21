class Permissions::PostVotePollRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      true
    end
  end

  def update(post_vote_poll_id:)
   
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
