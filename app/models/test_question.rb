class TestQuestion < ActiveRecord::Base

  include ModelValidator::CustomErrorable

  belongs_to :post_test
  has_many :test_answer_variants, dependent: :destroy
  belongs_to :content, polymorphic: true
  belongs_to :on_answered_m_content, polymorphic: true
  #

  def validation_service
    ModelValidator::TestQuestion.new(self)
  end

  def self.factory
    Services::TestQuestion::Factory
  end

  def updater
    Services::TestQuestion::Updater.new(self)
  end

  def self.updater
    Services::TestQuestion::Updater
  end

  #required for serialization, for e.g. methods #like post_size_url on PostImage
  def s_content_json
    case self.content
    when PostImage
      self.content.as_json(methods: [:post_size_url])
    end
  end

  def s_on_answered_m_content_json
    case self.on_answered_m_content
    when PostImage
      self.on_answered_m_content.as_json(methods: [:post_size_url])
    end
  end

end
 