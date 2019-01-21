class Discussion < Model

  register

  attributes :id, :discussable_type, :discussable_id, :messages_count

  has_many :discussion_messages, class_name: 'DiscussionMessage'

  route :Show, {get: "discussions/:discussable_id"}


  # def self.after_route_show(response)
  #   jsoned_response = response.json

  #   discussion = Discussion.parse(jsoned_response[:discussion])

  #   message_authors = User.parse(jsoned_response[:message_authors])

  #   cached_authors = {}

  #   message_authors.each do |author|
  #     cached_authors[author.id] = author
  #   end

  #   sorted_messages = sort_by_parent_child(discussion.discussion_messages)
  # end

  # def sort_by_parent_child(array)

  #   target_hash = Hash.new { |h,k| h[k] = { id: nil, message: DiscussionMessage.new } }

  #   array.each do |message|
  #       id, parent_id = message.id, (!!(x  = message.discussion_message_id) ? x : 0)
  #       target_hash[id][:id] = message.id
  #       target_hash[id][:message] = message
  #       target_hash[parent_id][:message].children_messages << target_hash[id][:message]
  #   end

  #   target_hash[0][:message]

  # end

end
