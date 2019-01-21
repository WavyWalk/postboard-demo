class Permissions::DiscussionMessageRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      return true
    else
      return false
    end
  end

end
