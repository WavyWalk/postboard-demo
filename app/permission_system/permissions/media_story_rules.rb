class Permissions::MediaStoryRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      return true
    else
      return false
    end
  end

  def update(media_story_id)
    if @current_user
      media_story = MediaStory.find(media_story_id)
      if media_story.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
        return true        
      end
    end
  end

end