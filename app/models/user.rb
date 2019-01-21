class User < ActiveRecord::Base


  include ModelValidator::CustomErrorable
  #ASSOCIATIONS
  has_many :discussion_messages, dependent: :destroy

  has_one :user_denormalized_stat

  has_one :user_karma, dependent: :destroy

  has_many :posts, foreign_key: 'author_id'

  has_many :post_karma_transactions

  has_many :discussion_message_karma_transactions, dependent: :destroy

  has_many :user_role_links, dependent: :destroy

  has_many :user_roles, through: :user_role_links

  has_many :user_subscriptions

  has_many :subscribing_user_subscriptions, class_name: 'UserSubscription', foreign_key: :to_user_id

  has_many :subscribers, through: :subscribing_user_subscriptions, source: :user

  has_many :oauth_credentials

  has_many :post_tests

  has_many :notifications

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  #this accessor serves for:
  #includes does not support sending arguments
  #so for using includes with ability to pass arguments for it
  #association fetches with lambda which itself reads from static accessor and uses it in where clause
  #the caller should specify the arg as well as clean up after
  class << self
    attr_accessor :current_user_id_for_argless_includes
  end
  has_one :usub_with_current_user, ->{ where(user_id: User.current_user_id_for_argless_includes) }, class_name: 'UserSubscription', foreign_key: :to_user_id


  #END ASSOCIATIONS
  #AUTHENTICATION
  has_one :user_credential, dependent: :destroy
  has_one :uc_s_name, ->{ select(:id, :user_id, :name) }, class_name: 'UserCredential'


  validates_associated :user_credential
  # END AUTHENTICATION

  def self.qo_service
    ::ModelQuerier::User
  end

  def role_service
    @_role_service ||= UserSubClassServices::Role.new(self)
  end

  def updater
    Services::User::Updater.new(self)
  end

end
