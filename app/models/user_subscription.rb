class UserSubscription < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :to_user, class_name: 'User', foreign_key: :to_user_id 

  def validation_service
    @_validation_service ||= ModelValidator::UserSubscription.new(self)
  end

  def self.qo
    ModelQuerier::UserSubscription
  end

end
