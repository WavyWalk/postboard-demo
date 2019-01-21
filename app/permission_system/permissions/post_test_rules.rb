class Permissions::PostTestRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      true
    else
      false
    end
  end

  def update
    if @current_user && @current_user.role_service.has_roles?('staff')
      true
    else
      false
    end
  end

  def personality_test_new
    if @current_user && @current_user.registered
      true
    else
      false
    end
  end

end
