class Permissions::PostRules < Permissions::Base

  def create
    if @current_user
      true
    else
      false
    end
  end


  def staff_create
    must_have_staff_role
  end



  def staff_edit
    must_have_staff_role
  end


  def staff_user_submitted_unpublished_index
    must_have_staff_role
  end

  def staff_user_submitted_update
    must_have_staff_role
  end



  def staff_user_submitted_unpublished_set_published
    must_have_staff_role
  end


  def staff_user_submitted_unpublished_set_unpublished
    must_have_staff_role
  end


  def staff_posts_search
    must_have_staff_role
  end


  def users_index(user_id)
    if @current_user.id == @current_user.id
      true
    else
      false
    end
  end


  def must_have_staff_role
    if @current_user && @current_user.role_service.has_roles?('staff')
     true
    else
     false
    end
  end

end
