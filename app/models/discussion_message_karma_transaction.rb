class DiscussionMessageKarmaTransaction < ActiveRecord::Base

  belongs_to :discussion_message_karma
  belongs_to :user

  def self.qo
    ModelQuerier::DiscussionMessageKarmaTransaction
  end
  #necessary for returning a value on which amount the karma changed
  #to change it in client's view
  #should be send in json when made
  attr_accessor :user_change_amount
end
