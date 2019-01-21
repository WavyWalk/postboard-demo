class PostKarma < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :post
  has_many :post_karma_transactions, dependent: :destroy

  class << self
    attr_accessor :current_user_id_as_post_karma_transaction_owner_for_argless_includes
  end
  #requires current_user_id_as_post_karma_transaction_owner_for_argless_includes be set with user id; this is necessary for later to be able to use includes
  has_one :pkt_cu, ->{ where(user_id: PostKarma.current_user_id_as_post_karma_transaction_owner_for_argless_includes) }, class_name: 'PostKarmaTransaction'

  #END ASSOCIATIONS

  


  #helpers
  def is_hot?
    !!self.hot_since
  end


end
