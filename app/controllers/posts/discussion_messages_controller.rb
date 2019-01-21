class Posts::DiscussionMessagesController < ApplicationController

  def create

    build_permissions DiscussionMessage

    if !@permission_rules.create

      render json: {errors: {general: 'no_name'}} 
      return
    end

    cmpsr  = ComposerFor::Posts::DiscussionMessages::Create.new(DiscussionMessage.new, params, self)

    cmpsr.when(:ok) do |discussion_message|
      render json: AsJsonSerializer::Posts::DiscussionMessages::Create.new(discussion_message).success
    end

    cmpsr.when(:validation_error) do |discussion_message|
      render json: AsJsonSerializer::Posts::DiscussionMessages::Create.new(discussion_message).error
    end

    cmpsr.run

  end

end
