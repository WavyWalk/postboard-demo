class Permissions::PostTestGradationRules < Permissions::Base

  def create(post_test_id:)
    if @current_user
      post_test = PostTest.where(id: post_test_id).first
      if post_test
        if post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        end
      end
    else 
      false
    end
  end

  def destroy(id:)
    if @current_user
      post_test = PostTest.joins(:post_test_gradations)
      .where(post_test_gradations: {id: id}).first
    
      if post_test
        if post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        end
      end
    else 
      false
    end
  end

end
