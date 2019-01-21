class PostTag < ActiveRecord::Base





  include ModelValidator::CustomErrorable




  has_many :post_tag_links
  has_many :posts, through: :post_tag_links





  SPECIAL_TAGS = ['ad']


  # =>    SERVICE ACCESSORS`

  def self.qo_service
    ModelQuerier::PostTag.new
  end





  def validation_service
    @_validation_service ||= ModelValidator::PostTag.new(self)
  end




  def self.factory
    Services::PostTag::Factory.new
  end


  # =>    END SERVICE ACCESSORS

end
