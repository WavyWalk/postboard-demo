class DiscussionMessage < Model

  register

  attributes :id, :discussion_id, :user_id, :content, :discussion_message_id

  has_many :children_messages, class_name: 'DiscussionMessage'

  has_one :user, class_name: 'User'

  has_one :discussion_message_karma, class_name: 'DiscussionMessageKarma'

  route :create, {post: "discussion_messages"}

  def self.wysi_textarea_parse_rules
    (` 
      {
        colspan: "numbers",
        tags: {
          p: {},
          h3: {},
          img: {
            check_attributes: {
              "data-*": "any",
              src: "src"
            }
          }
        }
      }
    `)
  end

end
