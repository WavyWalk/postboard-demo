class Permissions::TestQuestionRules < Permissions::Base

  def create(post_test_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      post_test = PostTest.where(id: post_test_id, user_id: @current_user.id).first
      if post_test || @current_user.role_service.has_roles?('staff')
        true
      else
        false
      end
    else
      false
    end
  end

  def update(post_test_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      post_test = PostTest.where(id: post_test_id, user_id: @current_user.id).first
      if post_test || @current_user.role_service.has_roles?('staff')
        true
      else
        false
      end
    else
      false
    end
  end

  def destroy(test_question_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      post_test = PostTest.joins(:test_questions)
      .where(post_tests: {user_id: @current_user.id})
      .where(test_questions: {id: test_question_id})
      .first
      if post_test || @current_user.role_service.has_roles?('staff')
        true
      else
        false
      end
    else
      false
    end
  end

  def update_content_image(test_question_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      test_question = TestQuestion.where(id: test_question_id).first
      if test_question
        if test_question.post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        end
      else
        false
      end
    else
      false
    end
  end

  def personality_test_destroy(post_test_id:, id:)
    if @current_user
      test_question = TestQuestion.find(id)
      if test_question.post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
        if test_question.post_test.id = post_test_id
          return true
        end
      end
    end
  end

end
