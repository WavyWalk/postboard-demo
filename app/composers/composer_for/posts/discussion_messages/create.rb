class ComposerFor::Posts::DiscussionMessages::Create < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @params = params
    @controller = controller
    @options = options
  end

  def before_compose
    permit_attributes
    assign_attributes
    find_and_set_discussion
    assign_parent_id_if_parent_id_is_in_params
    validate_discussion_to_exist
    assign_user_id_to_current_user
    build_and_assign_discussion_message_karma
    validate_discussion_message
    increment_discussion_message_count
  end

  def permit_attributes
    @permitted_attributes = @params.require(:discussion_message).permit(:discussion_id, :content)
  end

  def assign_attributes
    @model.attributes = @permitted_attributes
  end

  def find_and_set_discussion
    @discussion = Discussion.where(id: @model.discussion_id, discussable_type: 'Post').select(:id, :messages_count).first
  end

  def assign_parent_id_if_parent_id_is_in_params
    if dm_id = @params[:discussion_message][:discussion_message_id]
      @model.discussion_message_id = dm_id
    end
  end

  def validate_discussion_to_exist
    #discussion = Discussion.where(id: @model.discussion_id, discussable_type: 'Post').select(:id).first
    if !@discussion
      @model.add_error(:content, 'commented post has been deleted or comments to post where turned off')
      fail_immediately(:submitted_to_non_existant_discussion)
    end
  end

  def assign_user_id_to_current_user
    @model.user_id = @controller.current_user.id
  end



  def build_and_assign_discussion_message_karma
    @discussion_message_karma = DiscussionMessageKarma.new(count: 0)
    @model.discussion_message_karma = @discussion_message_karma
  end




  def validate_discussion_message
    ModelValidator::DiscussionMessage.new(@model).set_scenarios(:create_to_posts_discussion).validate
  end

  def increment_discussion_message_count
    @discussion.messages_count ||= 0
    @discussion.messages_count += 1
  end

  def compose
    @model.save!
    @discussion.save!
    add_karma_to_author_for_comment_creation
  end



  def add_karma_to_author_for_comment_creation
    
    karma = @controller.current_user.user_karma
    karma.updater.add_for_comment_creation
    karma.save!
    
  end



  def resolve_success
    publish :ok, @model
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      publish :validation_error, @model
    else
      raise e
    end

  end

end 
