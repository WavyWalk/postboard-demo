class MediaStory < ActiveRecord::Base
  
  include ModelValidator::CustomErrorable

  #title
  has_many :media_story_nodes, dependent: :destroy
  belongs_to :user
  


  def validation_service
    ModelValidator::MediaStory.new(self)
  end

  def self.factory
    Services::MediaStory::Factory
  end

  def self.composer_helper
    Services::MediaStory::ComposerHelper    
  end

  def json_for_post_node
    AsJsonSerializer::MediaStories::Create.new(self).success
  end

  def json_for_post_node_er
    AsJsonSerializer::MediaStories::Create.new(self).error
  end
  

end
 