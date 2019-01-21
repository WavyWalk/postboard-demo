#if named PostTests for some reason conflict with Rails autoloader
class Services::Post::SNodesUpdater::PostTestsRelated 
  
  def self.update_when_post_test_updated(post_test)
    posts = find_posts(post_test)

    posts.each do |post|
      update_post_test(post, post_test)
    end
  end  

  def self.find_posts(post_test)
    posts = ::Post
      .qo_service
      .all_related_to_post_test(post_test)
      .get_result

  end

  def self.update_post_test(post, post_test)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, post_test.id)

    copy_and_replace_keys(
      post_test_node, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_post_test_updated(post_test)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.copy_and_replace_keys(hash_to_update, new_hash)
    new_hash.each do |k,v|
      hash_to_update[k] = v
    end
  end


  def self.assign_s_nodes_and_save(post, s_nodes)
    post.s_nodes = s_nodes.to_json
    post.save!
  end


  def self.prepare_s_nodes(post)
    JSON.parse post.s_nodes
  end
  

  def self.update_when_test_question_created(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      add_test_question(post, test_question)
    end
  end


  def self.add_test_question(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test.id)

    post_test_node['test_questions'] << ::Services::PostTest::SerializerForSNodes.serialize_when_test_question_created(test_question)

    assign_s_nodes_and_save(post, s_nodes)
  end


  def self.update_when_test_question_updated(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      update_test_question(post, test_question)
    end
  end

  def self.update_test_question(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test.id)

    serialized_test_question = find_test_question(post_test_node, test_question.id)
    
    copy_and_replace_keys(
      serialized_test_question, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_update_test_question(test_question)
    )
    
    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.find_post_test_node(s_nodes, post_test_id)
    post_node = s_nodes.find do |pn|
      pn['node_id'] == post_test_id && pn['node_type'] == 'PostTest'
    end
    post_node['node']
  end

  def self.find_test_question(post_test_node, test_question_id)
    post_test_node['test_questions'].find do |tq|
      tq['id'] == test_question_id
    end
  end

  def self.when_test_question_destroyed(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      delete_test_question(post, test_question)
    end
  end

  def self.delete_test_question(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test_id)

    post_test_node['test_questions'].delete_if do |tq|
      tq['id'] == test_question.id
    end

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.when_test_answer_variant_created(test_answer_variant)
    posts = find_posts(test_answer_variant.test_question.post_test)

    posts.each do |post|
      add_test_answer_variant(post, test_answer_variant)
    end
  end

  def self.add_test_answer_variant(post, test_answer_variant)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(
      s_nodes,
      test_answer_variant.test_question.post_test_id
    )
    
    question = find_question(
      post_test_node, 
      test_answer_variant.test_question_id
    )
    
    question['test_answer_variants'] << ::Services::PostTest::SerializerForSNodes.serialize_when_test_answer_variant_created(test_answer_variant)

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.find_question(post_test_node, test_question_id)
    post_test_node['test_questions'].find do |tq|
      tq['id'] == test_question_id
    end
  end

  def self.update_when_test_answer_variant_updated(test_answer_variant)
    posts = find_posts(test_answer_variant.test_question.post_test)

    posts.each do |post|
      update_variant(post, test_answer_variant)
    end
  end

  def self.update_variant(post, test_answer_variant)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(
      s_nodes,
      test_answer_variant.test_question.post_test_id
    )

    question = find_question(
      post_test_node, test_answer_variant.test_question_id
    )

    variant = find_variant(question, test_answer_variant)


    copy_and_replace_keys(
      variant, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_answer_variant_updated(test_answer_variant)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_test_answer_variant_content_updated(test_answer_variant)
    posts = find_posts(test_answer_variant.test_question.post_test)

    posts.each do |post|
      update_test_answer_variant_content(post, test_answer_variant)
    end
  end

  def self.update_when_test_answer_variant_content_destroyed(test_answer_variant)
    posts = find_posts(test_answer_variant.test_question.post_test)

    posts.each do |post|
      remove_test_answer_variant_content(post, test_answer_variant)
    end
  end

  def self.remove_test_answer_variant_content(post, test_answer_variant)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(
      s_nodes,
      test_answer_variant.test_question.post_test_id
    )

    question = find_question(
      post_test_node, test_answer_variant.test_question_id
    )

    variant = find_variant(question, test_answer_variant)


    copy_and_replace_keys(
      variant, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_answer_variant_content_destroyed(test_answer_variant)
    )

    variant.delete(:content)

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_test_answer_variant_content(post, test_answer_variant)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(
      s_nodes,
      test_answer_variant.test_question.post_test_id
    )

    question = find_question(
      post_test_node, test_answer_variant.test_question_id
    )

    variant = find_variant(question, test_answer_variant)


    copy_and_replace_keys(
      variant, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_answer_variant_content_updated(test_answer_variant)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.find_variant(question, test_answer_variant)
    question['test_answer_variants'].find do |var|
      var['id'] == test_answer_variant.id
    end    
  end

  def self.update_when_test_answer_variant_destroyed(test_answer_variant)
    posts = find_posts(test_answer_variant.test_question.post_test)

    posts.each do |post|
      remove_test_answer_variant(post, test_answer_variant)
    end
  end

  def self.remove_test_answer_variant(post, test_answer_variant)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(
      s_nodes,
      test_answer_variant.test_question.post_test_id
    )

    question = find_question(
      post_test_node, test_answer_variant.test_question_id
    )

    question['test_answer_variants'].delete_if do |var|
      var['id'] == test_answer_variant.id
    end

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_post_test_thumbnail_updated(post_test)
    posts = find_posts(post_test)

    posts.each do |post|
      update_post_test_thumbnail(post, post_test)
    end
  end

  def self.update_post_test_thumbnail(post, post_test)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, post_test.id)

    copy_and_replace_keys(
      post_test_node, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_post_test_thumbnail_updated(post_test)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_test_question_content_image_updated(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      udpate_test_question_content_image(post, test_question)
    end
  end

  def self.udpate_test_question_content_image(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test_id)

    question = find_question(post_test_node, test_question.id)

    copy_and_replace_keys(
      question, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_question_content_image_updated(test_question)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_test_question_content_image_destroyed(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      remove_content_image_from_test_question(post, test_question)
    end
  end

  def self.remove_content_image_from_test_question(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test_id)

    question = find_question(post_test_node, test_question.id)

    copy_and_replace_keys(
      question, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_question_content_image_updated(test_question)
    )

    question.delete(:content)

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_test_question_on_answered_m_content_updated(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      update_test_question_on_answered_m_content(post, test_question)
    end
  end

  def self.update_test_question_on_answered_m_content(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test_id)

    question = find_question(post_test_node, test_question.id)

    copy_and_replace_keys(
      question, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_question_on_answered_m_content_updated(test_question)
    )

    assign_s_nodes_and_save(post, s_nodes)
  end

  def self.update_when_test_question_on_answered_m_content_destroyed(test_question)
    posts = find_posts(test_question.post_test)

    posts.each do |post|
      remove_on_answered_m_content_from_test_question(post, test_question)
    end
  end

  def self.remove_on_answered_m_content_from_test_question(post, test_question)
    s_nodes = prepare_s_nodes(post)

    post_test_node = find_post_test_node(s_nodes, test_question.post_test_id)

    question = find_question(post_test_node, test_question.id)

    copy_and_replace_keys(
      question, 
      ::Services::PostTest::SerializerForSNodes.serialize_when_test_question_on_answered_m_content_updated(test_question)
    )

    question.delete(:on_answered_m_content)

    assign_s_nodes_and_save(post, s_nodes)
  end

end
