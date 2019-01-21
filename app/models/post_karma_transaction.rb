class PostKarmaTransaction < ActiveRecord::Base
  include ModelValidator::CustomErrorable
  #ASSOCIATIONS
  belongs_to :post_karma
  belongs_to :user
  #END ASSOCIATIONS
  #necessary for returning a value on which amount the karma changed
  #to change it in client's view
  #should be send in json when made 
  attr_accessor :user_change_amount
end
