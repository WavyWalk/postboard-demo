class Posts::DiscussionsController < ApplicationController

  def show 
    post_id = params[:id]

    discussion = ModelQuerier::Discussion.show_by_post_id( post_id )

    uniq_users_ids_for_messages = discussion.discussion_messages.map(&:user_id).uniq

    message_authors = User.qo_service.get_by_ids_with_karmas(uniq_users_ids_for_messages)

    render json: {
       discussion: AsJsonSerializer::Discussion::PostsShow.new(discussion).success,
       message_authors: message_authors.as_json(include: [:user_karma])
     }
  end

end
