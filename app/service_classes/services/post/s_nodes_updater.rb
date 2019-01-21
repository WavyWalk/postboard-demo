class Services::Post::SNodesUpdater
  

  def self.update_where_post_text_is(post_text)
    post = post_text.post

    
    s_nodes = JSON.parse(post.s_nodes)
    
    if self.update_in_s_nodes_where('PostText', post_text.id, {content: post_text.content}, s_nodes)
      post.s_nodes = s_nodes.to_json
      post.save!
    end
  
  end 

  #this mutatest in place
  def self.update_in_s_nodes_where(type, id, update_hash, s_nodes)
    found = false
    s_nodes.each do |post_node|
      
      if post_node['node_type'] == type
        
        if node = post_node['node']

          if node['id'] == id
            found = true
          
            update_hash.each do |k,v|
              node[k] = v
            end

          end

        end


      end
    
    end

    found
  end

  def self.delete_where_post_text_is(post_text)    
    post = post_text.post
    post_node = post_text.post_node
    
    s_nodes = JSON.parse(post.s_nodes)

    if delete_post_node_with_id(post_node.id, s_nodes)
      post.s_nodes = s_nodes.to_json
      post.save!
    end
  end


  def self.delete_post_node(post, post_node)
    s_nodes = JSON.parse(post.s_nodes)

    if delete_post_node_with_id(post_node.id, s_nodes)
      post.s_nodes = s_nodes.to_json
      post.save!
    end
  end

  def self.delete_post_node_with_id(id, s_nodes)
    found = false
    s_nodes.delete_if do |post_node|
      if post_node['id'] == id
        found = true
      end
    end
    found
  end
  

  def self.insert_new_post_node_at_position(post, post_node, position)
    s_nodes = JSON.parse(post.s_nodes)
    if position < 0
      return ['invalid position for node insertion']
    end
    if s_nodes.length < position
      return ['invalid position for node insertion']
    end
    s_nodes.insert(position, post_node.serialize_as_json_for_s_node)
    post.s_nodes = s_nodes.to_json
    post.save!
    #indicates that no errors where found
    #if errors are returns Array of String
    return false
  end
  
end
