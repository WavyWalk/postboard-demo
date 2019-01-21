class VotePollOption < ActiveRecord::Base

  include ModelValidator::CustomErrorable


  belongs_to :post_vote_poll
  has_many :vote_poll_transactions, dependent: :destroy
  belongs_to :m_content, polymorphic: true


  def self.factory
    ::Services::VotePollOption::Factory
  end

  def validation_service
    @_validation_service ||= ModelValidator::VotePollOption.new(self)
  end

  def serialize_with_children
    self.as_json(
      include: [:m_content]
    )
  end

end
