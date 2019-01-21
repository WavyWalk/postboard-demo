class Discussion < ActiveRecord::Base
  
  belongs_to :discussable, polymorphic: true

  has_many :discussion_messages, dependent: :destroy

end
