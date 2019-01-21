class PostVotePoll < Model
  
  register

  attributes :id, :vote_poll_options, :s_options, :question, :loaded, :m_content_id, :m_content_type
  has_many :vote_poll_options, class_name: 'VotePollOption'
  has_one :m_content, polymorphic_type: :m_content_type

  route :create, post: 'post_vote_polls'

  route :load_counts, {get: 'post_vote_polls/counts/:id'}, {defaults: [:id]}
  route :Show, {get: 'post_vote_polls/:id'}, {defaults: [:id]}
  route :update, {put: 'post_vote_polls/:id'}, {defaults: [:id]}
  route :destroy, {delete: 'post_vote_polls/:id'}, {defaults: [:id]}


  def after_route_load_counts(r)
    ids_map = {}
    self.vote_poll_options.each do |vote_option|
      ids_map[vote_option.id] = vote_option
    end
    options = VotePollOption.parse(r.response.json)
    options.each do |new_option|
      ids_map[new_option.id].count = new_option.count
    end
    self.arbitrary['loaded'] = true
    r.promise.resolve self
  end

  def init(attributes)
    if x = attributes[:s_options]
      self.s_options = VotePollOption.parse(JSON.parse(x))
    end
  end

  def get_max_count_option
    sorted_by_count = self.vote_poll_options.data.sort do |a,b|
      a.count <=> b.count
    end

    maximal = sorted_by_count[-1]
    if maximal
      return maximal.count      
    else
      return 0
    end

  end


end