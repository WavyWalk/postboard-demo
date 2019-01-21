class Services::MediaStory::ComposerHelper
  
  class << self

    def update_or_initialize_with_error_when_added_to_post(attributes_hash:)
      media_story = ::MediaStory.where(id: attributes_hash[:id]).first

      if media_story
        return media_story
      else
        media_story = ::MediaStory.new
        media_story.add_custom_error(:general, "not found")
        return media_story
      end
      
      raise Exception.new('unreachable reached')
    end

  end
  
end
