class Permissions::PostKarmaRules < Permissions::Base

  def staff_count_update
    must_have_staff_role
  end

  def must_have_staff_role
    if @current_user && @current_user.role_service.has_roles?('staff')
     true
    else
     false
    end
  end

end
