class Services::PostThumb::Factory

  def self.initialize_with_node_when_creating_post(attributes)

    node = case attributes[:node_type]
          when 'PostText'
            initialize_post_text_when_creating_post(attributes[:node])
          when 'PostImage'
            find_and_update_post_image_or_init_with_error_when_creating_post(attributes[:node])
          # when 'PostGif'
          #   find_and_update_post_gif_or_init_with_error_when_creating_post(attributes[:node])
          # when 'VideoEmbed'
          #   initialize_video_embed_when_creating_post(attributes[:node])
          else
            raise "unknown type provided #{self.name}.initialize_with_node_when_creating_post"
          end

    if node.is_a?(PostText)
      if node.content.length > 120
        node.add_custom_error(:content, 'too long')
      end
    end

    node.validation_service.set_scenarios(:post_create).validate

    post_thumb = ::PostThumb.new
    post_thumb.node = node
    post_thumb

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

  # def self.find_and_update_post_gif_or_init_with_error_when_creating_post(attributes)
  #   ::PostGif.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  # end

  # def self.initialize_video_embed_when_creating_post(attributes)
  #   video_embed = ::VideoEmbed.new(attributes)
  #   video_embed.updater.assign_provider_depending_on_link
  #   video_embed
  # end

end
