class PostVotePoll < ActiveRecord::Base
  
  belongs_to :user
  has_one :post_node, as: :node
  has_many :vote_poll_options, dependent: :destroy
  belongs_to :m_content, polymorphic: true
  
  validates_associated :vote_poll_options

  include ModelValidator::CustomErrorable

  def validation_service
    @_validation_service ||= ModelValidator::PostVotePoll.new(self)
  end

  def updater_service
    @_udpater_service ||= ::Services::PostVotePoll::Updater.new(self)
  end

  def self.qo
    ModelQuerier::PostVotePoll.new(self)
  end

  def self.composer_helper
    Services::PostVotePoll::ComposerHelper
  end

  def self.factory
    Services::PostVotePoll::Factory
  end

  def json_for_post_node
    self.as_json
  end

  def json_for_post_node_er
    self.as_json(methods: [:errors])
  end

end
