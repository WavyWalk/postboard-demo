class PostTagLink < ActiveRecord::Base
  belongs_to :post
  belongs_to :post_tag
end
