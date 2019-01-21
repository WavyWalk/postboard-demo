class VotePollOption < Model
  register

  attributes :id, :vote_poll_transactions, :post_vote_poll_id, :content, :count, :m_content_id, :m_content_type

  has_many :vote_poll_transactions, class_name: 'VotePolltransaction'
  has_one :m_content, polymorphic_type: :m_content_type

  route :create, {post: 'post_vote_polls/:post_vote_poll_id/vote_poll_options'}, {defaults: [:post_vote_poll_id]}
  route :update, {put: 'post_vote_polls/:post_vote_poll_id/vote_poll_options/:id'}, {defaults: [:post_vote_poll_id, :id]}
  route :destroy, {delete: 'post_vote_polls/:post_vote_poll_id/vote_poll_options/:id'}, {defaults: [:post_vote_poll_id, :id]}


end