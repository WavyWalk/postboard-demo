class Services::PostNode::Factory

  def self.initialize_with_node_when_creating_post(attributes)

    node = case attributes[:node_type]
          when 'PostText'
            initialize_post_text_when_creating_post(attributes[:node])
          when 'PostImage'
            find_and_update_post_image_or_init_with_error_when_creating_post(attributes[:node])
          when 'PostGif'
            find_and_update_post_gif_or_init_with_error_when_creating_post(attributes[:node])
          when 'VideoEmbed'
            initialize_video_embed_when_creating_post(attributes[:node])
          when 'PostVotePoll'
            initialize_post_vote_poll_when_creating_post(attributes[:node])
          when 'PostTest'
            if (attributes[:node] ||= {})[:is_personality]
              initialie_personality_test_when_creating_post(attributes[:node])
            else
              initialize_post_test_when_creating_post(attributes[:node])
            end
          when 'MediaStory'
            initialize_media_story_when_creating_post(attributes[:node])
          else
            raise "unknown type provided #{self.name}.initialize_with_node_when_creating_post"
          end

    node.validation_service.set_scenarios(:post_create).validate

    post_node = ::PostNode.new
    post_node.node = node
    post_node

  end

 private

  def self.initialize_post_text_when_creating_post(attributes)
    ::PostText.factory
            .build(attributes)
            .sanitize_content
            .get_result
  end

  def self.find_and_update_post_image_or_init_with_error_when_creating_post(attributes)
    ::PostImage.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end

  def self.find_and_update_post_gif_or_init_with_error_when_creating_post(attributes)
    ::PostGif.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end

  def self.initialize_video_embed_when_creating_post(attributes)
    video_embed = ::VideoEmbed.where(id: attributes['id']).first
    unless video_embed
      return VideoEmbed.new.add_custom_error(:link, 'invalid video')
    end
    return video_embed
  end

  def self.initialize_post_vote_poll_when_creating_post(attributes)
    ::PostVotePoll.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end

  def self.initialize_post_test_when_creating_post(attributes)
    ::PostTest.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)    
  end

  def self.initialie_personality_test_when_creating_post(attributes)
    ::PostTest.composer_helper.update_or_initialize_personality_test_with_error_when_added_to_post(attributes_hash: attributes)
  end

  def self.initialize_media_story_when_creating_post(attributes)
    ::MediaStory.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end

end
