class Services::Post::SNodesUpdater::PostVotePolls
  

  def self.update_when_vote_poll_option_destroyed(post, post_vote_poll_id, vote_poll_option_id)  
    s_nodes = prepare_s_nodes(post)
    
    s_post_vote_poll = s_nodes.find do |node|
      node['node_id'] == post_vote_poll_id && node['node_type'] == 'PostVotePoll'
    end

    s_post_vote_poll['node']['vote_poll_options'].delete_if do |s_vote_poll_option|
      s_vote_poll_option['id'] == vote_poll_option_id
    end

    post.s_nodes = s_nodes.to_json
    
    post.save!    
  end


  def self.update_when_vote_poll_option_updated(vote_poll_option)
    posts = ::Post.qo_service
                 .all_related_to_vote_poll_option(vote_poll_option)
                 .get_result

    posts.each do |post|
      self.update_vote_poll_option(
        post, 
        vote_poll_option.post_vote_poll_id, 
        vote_poll_option
      )
    end

  end


  def self.update_when_vote_poll_option_created(vote_poll_option)
    posts = ::Post.qo_service
      .all_related_to_vote_poll_option(vote_poll_option)
      .get_result

    posts.each do |post|
      self.add_new_vote_poll_option(post, vote_poll_option)
    end
  end

  def self.add_new_vote_poll_option(post, vote_poll_option)
    s_nodes = prepare_s_nodes(post)

    post_node = s_nodes.find do |pn|
      pn['node_id'] == vote_poll_option.post_vote_poll_id && pn['node_type'] == 'PostVotePoll'
    end

    post_node['node']['vote_poll_options'] << vote_poll_option.serialize_with_children

    post.s_nodes = s_nodes.to_json

    post.save!
  end

  def self.update_when_post_vote_poll_updated(post_vote_poll)
    posts = ::Post.qo_service
      .all_related_to_post_vote_poll(post_vote_poll)
      .get_result

    posts.each do |post|
      update_post_vote_poll(post, post_vote_poll)
    end
  end

  def self.update_post_vote_poll(post, post_vote_poll)
    s_nodes = prepare_s_nodes(post)

    post_node = s_nodes.find do |post_node|
      post_node['node_id'] == post_vote_poll.id && post_node['node_type'] == 'PostVotePoll' 
    end

    old_post_vote_poll = post_node['node']

    post_vote_poll.as_json.each do |k,v|
      old_post_vote_poll[k] = v  
    end

    post.s_nodes = s_nodes.to_json

    post.save!
  end

  def self.prepare_s_nodes(post)
    JSON.parse(post.s_nodes)
  end

  def self.update_vote_poll_option(post, vote_poll_id, vote_poll_option)
  
    s_nodes = prepare_s_nodes(post)

    post_node = s_nodes.find do |node|
      node['node_id'] == vote_poll_id && node['node_type'] == 'PostVotePoll'
    end

    post_vote_poll = post_node['node']

    post_vote_poll['vote_poll_options'].map! do |option|
      if option['id'] == vote_poll_option.id
        vote_poll_option.serialize_with_children
      else
        option
      end
    end

    post.s_nodes = s_nodes.to_json

    post.save

  end
  
end
