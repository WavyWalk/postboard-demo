class Permissions::PersonalityTestRules < Permissions::Base

  def create
    if @current_user && @current_user.registered
      true
    else
      false
    end
  end

  def edit(id)
    if @current_user || @current_user.role_service.has_roles?('staff')
      post_test = PostTest.find(id)
      if post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
        return true
      end
    end
  end

end
