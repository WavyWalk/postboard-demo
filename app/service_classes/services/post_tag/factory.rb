class Services::PostTag::Factory

  def create_collection_for_post_create(post_tags_hash)

      

      tag_names = (post_tags_hash ||= []).map do |pt|
        pt[:name].mb_chars.downcase.to_s.strip.squeeze(' ')
      end

      existing_post_tags = PostTag.where("name in (?)", tag_names)

      

      non_existent_post_tags = ( tag_names -= existing_post_tags.map(&:name) )

      

      new_post_tags = non_existent_post_tags.inject([]) do |accumulator, pt_name|

        post_tag = PostTag.new(name: pt_name)

        #WARNING: this will not render errors it will just remove invalid tags
        #it relies on client side validation, so only valid tags are expected to come through
        #if tag is invalid it means that user frauded POST request.
        post_tag_validator = post_tag.validation_service
        post_tag_validator.set_scenarios(:regular_create).validate

        unless post_tag.has_custom_errors?
          accumulator << post_tag
        end

        accumulator

      end

      

      post_tags = ( existing_post_tags += new_post_tags )

      post_tags

  end

end
