class VotePollTransaction < Model
  register
  
  attributes :id, :post_vote_poll_id, :vote_poll_option_id, :type, :user_id

  route :create, post: 'vote_poll_transactions'
    
end