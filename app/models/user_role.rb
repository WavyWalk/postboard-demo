class UserRole < ActiveRecord::Base

  ADMIN = 'admin'
  GUEST = 'guest'
  NO_NAME = 'no_name'
  STAFF  = 'staff'
  NO_EMAIL = 'no_email'
  EMAIL_PROVIDED = 'email_provided'
  NAME_PROVIDED = 'name_provided'
  NO_EMAIL_OR_PASSWORD = 'no_e_or_p'

  PERMITTED_GLOBAL_ROLE_NAMES = [
    ADMIN, GUEST, NO_NAME, STAFF, NO_EMAIL, EMAIL_PROVIDED, NAME_PROVIDED, NO_EMAIL_OR_PASSWORD
  ]

  has_many :user_role_links

  has_many :users, through: :user_role_links

  #STRICT (that always run) valdates name to be in allowed names
  validate :name_should_be_in_allowed_range


  def name_should_be_in_allowed_range
    unless UserRole::PERMITTED_GLOBAL_ROLE_NAMES.include?(self.name)
      errors.add(:name, 'not allowed')
    end

  end






end
