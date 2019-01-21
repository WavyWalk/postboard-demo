class Permissions::TestAnswerVariantRules < Permissions::Base

  def create(test_question_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      post_test = find_post_test_by_question_id(test_question_id)
      if post_test
        if post_test.user_id = @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def update(test_question_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      post_test = find_post_test_by_question_id(test_question_id)
      if post_test
        if post_test.user_id = @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def destroy(test_answer_variant_id:)
    if @current_user && !@current_user.role_service.has_roles?('guest')
      post_test = PostTest.joins(test_questions: [:test_answer_variants])
      .where(post_tests: {user_id: @current_user.id})
      .where(test_answer_variants: {id: test_answer_variant_id})
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


  def find_post_test_by_question_id(test_question_id)
    PostTest.joins(:test_questions).where(test_questions: {id: test_question_id}).first
  end

  def update_content_image(test_answer_variant_id:)
    if @current_user && !@current_user.role_service.has_roles?("guest")
      test_answer_variant = TestAnswerVariant.where(id: test_answer_variant_id).first
      if test_answer_variant
        if test_answer_variant.test_question.post_test.user_id == @current_user.id || @current_user.role_service.has_roles?('staff')
          true
        end
      else
        false
      end
    else
      false
    end
  end

  def personality_test_create(params)
    test_question_id = params['test_answer_variant']['test_question_id']
    post_test = PostTest.joins(:test_questions).where('test_questions.id = ?', test_question_id).first
    return false unless (post_test && post_test.is_personality)
    if post_test.user_id == @current_user.id || @current_user.role_service.has_roles?("staff")
      return true
    end
  end

  def personality_test_destroy(id:)
    post_test = ::PostTest.joins(test_questions: [:test_answer_variants]).where('test_answer_variants.id = ?', id).first
    return false unless (post_test && post_test.is_personality)
    if @current_user 
      if (post_test.user_id == @current_user) || @current_user.role_service.has_roles?('staff') 
        return true
      end
    end
  end

end
