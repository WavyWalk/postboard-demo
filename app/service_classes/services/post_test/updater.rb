class Services::PostTest::Updater  

  def initialize(owner)
    @owner = owner
  end

  def update_when_added_to_post(attributes)
    if @owner.orphaned != false
      @owner.orphaned = false
      @owner.save
    else
      @owner
    end
  end

  def serialize_necessary_fields
    questions = @owner.test_questions.as_json(
      include: [
        {test_answer_variants: {methods: [:s_content_json]}},        
      ],
      methods: [:s_content_json, :s_on_answered_m_content_json]
    )
    thumbnail = @owner.thumbnail.json_for_post_node
    gradations = @owner.post_test_gradations.as_json(methods: [:s_content_json])

    @owner.s_questions = questions.to_json
    @owner.s_thumbnail = thumbnail.to_json
    @owner.s_gradations = gradations.to_json
  end

  def serialize_necessary_fields_and_save_and_update_s_nodes_on_related_posts
    serialize_necessary_fields
    @owner.save!
    @owner.post_node.post.updater.modify_s_node_post_test_and_save(@owner)
  end

end