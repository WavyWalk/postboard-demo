class DiscussionMessageKarma < ActiveRecord::Base

  belongs_to :discussion_message, dependent: :destroy

end
