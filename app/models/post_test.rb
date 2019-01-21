class PostTest < ActiveRecord::Base
   

  include ModelValidator::CustomErrorable 

  belongs_to :user
  belongs_to :thumbnail, class_name: 'PostImage', foreign_key: :thumbnail_id
  has_one :post_node, as: :node
  has_many :test_questions, dependent: :destroy
  has_many :post_test_gradations, dependent: :destroy
  has_many :post_test_stats, dependent: :destroy
  has_many :p_t_personalities, class_name: :P_T_Personality, dependent: :destroy

  def self.qo
    ModelQuerier::PostTest.new
  end

  def qo
    ModelQuerier::PostTest.new(self)
  end

  def updater
    Services::PostTest::Updater.new(self)
  end

  def validation_service
    ModelValidator::PostTest.new(self)
  end

  def personality_test_validation_service
    ModelValidator::PersonalityTest.new(self)
  end

  def self.factory
    Services::PostTest::Factory
  end

  def self.personality_factory
    Services::PersonalityTest::Factory
  end

  def self.composer_helper
    Services::PostTest::ComposerHelper
  end

  def json_for_post_node
    self.as_json
  end

  def json_for_post_node_er
    self.as_json(methods: [:errors])
  end

end
