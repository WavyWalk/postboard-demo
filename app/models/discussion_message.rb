class DiscussionMessage < ActiveRecord::Base


  include ModelValidator::CustomErrorable
  #ASSOCIATIONS
  belongs_to :user

  has_many :discussion_messages, dependent: :destroy

  belongs_to :discussion_message

  belongs_to :discussion

  has_one :discussion_message_karma
  #END ASSOCIATIONS

end
