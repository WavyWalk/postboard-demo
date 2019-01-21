class Permissions::PostGifRules < Permissions::Base

  def create
    if @current_user
      return true
    else
      return false
    end
  end

  def add_subtitles(post_gif_id)

    if @current_user
      post_gif = PostGif.find(post_gif_id)

      unless post_gif.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
        false
      else
        true
      end
    else
      false
    end

  end

end
