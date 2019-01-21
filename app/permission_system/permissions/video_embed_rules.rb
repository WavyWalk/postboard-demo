class Permissions::VideoEmbedRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      return true
    end
  end

end
