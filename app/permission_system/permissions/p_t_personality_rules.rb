class Permissions::P_T_PersonalityRules < Permissions::Base

  def create(post_test_id:)
    if @current_user
      post_test = PostTest.find(post_test_id)
      if post_test.user_id == @current_user.id || @current_user.role_service.has_roles('staff')
        if post_test.is_personality
          return true
        end
      end
    end
  end

  def destroy(post_test_id:)
    create(post_test_id: post_test_id)
  end

  def update(post_test_id:)
     create(post_test_id: post_test_id)
  end

  def medias_update(p_t_personality_id:)

    if @current_user
      post_test = PostTest.joins(:p_t_personalities).where('p_t_personalities.id = ?', p_t_personality_id).first
      if post_test.user_id == @current_user.id || @current_user.role_service.has_roles('staff')
        if post_test.is_personality
          return true
        end
      end
    end
  end

end
