class TestAnswerVariant < ActiveRecord::Base

  include ModelValidator::CustomErrorable

  belongs_to :test_question
  belongs_to :content, polymorphic: true
  has_many :personality_scales, dependent: :destroy


  def validation_service
    ModelValidator::TestAnswerVariant.new(self)
  end

  def self.factory
    Services::TestAnswerVariant::Factory
  end

  def updater
    Services::TestAnswerVariant::Updater.new(self)
  end

  def s_content_json
    case self.content
    when PostImage
      self.content.as_json(methods: [:post_size_url])
    end
  end

end
