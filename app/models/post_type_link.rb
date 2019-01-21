class PostTypeLink < ActiveRecord::Base
  belongs_to :post
  belongs_to :post_type
end
