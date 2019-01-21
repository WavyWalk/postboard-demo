class VotePollTransaction < ActiveRecord::Base
  belongs_to :post_vote_poll
  belongs_to :user
  belongs_to :vote_poll_option
end
