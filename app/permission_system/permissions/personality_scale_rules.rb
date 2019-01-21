class Permissions::PersonalityScaleRules < Permissions::Base

  def update(test_question_id:)
    if @current_user
      post_test = PostTest
        .where(user_id: @current_user.id)
        .joins(:test_questions)
        .where('test_questions.id = ?', test_question_id)
        .first
      if post_test || @current_user.role_service.has_roles?('staff')
        return true
      end
    end
  end

end
