class Permissions::MediaStoryNodeRules < Permissions::Base

  def update(media_story_id:, id:)
    if @current_user
      if media_story_author_is_current_user(media_story_id) || @current_user.role_service.has_roles?('staff')
        return true
      end
    end
  end

  def create(media_story_id:)
    if @current_user
      if media_story_author_is_current_user(media_story_id) || @current_user.role_service.has_roles?('staff')
        return true
      end
    end
  end

  def destroy(media_story_id)
    create(media_story_id: media_story_id)
  end

  def media_story_author_is_current_user(media_story_id)
    media_story = MediaStory.where(id: media_story_id, user_id: @current_user.id).first
    media_story ? true : false
  end

end
