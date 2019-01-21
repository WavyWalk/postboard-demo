class PostTestGradation < ActiveRecord::Base

  include ModelValidator::CustomErrorable

  belongs_to :post_test
  belongs_to :content, polymorphic: true
  
  def self.factory
    Services::PostTestGradation::Factory
  end

  def validation_service
    ModelValidator::PostTestGradation.new(self)
  end

  def updater
    Services::PostTestGradation::Updater.new(self)
  end

  def s_content_json
    case self.content
    when PostImage
      self.content.as_json(methods: [:post_size_url])
    end
  end

end
