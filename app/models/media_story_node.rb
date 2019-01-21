class MediaStoryNode < ActiveRecord::Base

  include ModelValidator::CustomErrorable
  #m_id
  #m_type
  #annotation
  validates_associated :media

  belongs_to :media_story
  belongs_to :media, polymorphic: true

  def validation_service
    ModelValidator::MediaStoryNode.new(self)
  end

  def self.factory
    Services::MediaStoryNode::Factory
  end

  def updater_service
    Services::MediaStoryNode::Updater.new(self)
  end

end
