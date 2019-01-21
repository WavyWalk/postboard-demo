class P_T_Personality < ActiveRecord::Base

  include ModelValidator::CustomErrorable

  belongs_to :media, polymorphic: true
  belongs_to :post_test
  has_many :personality_scales, dependent: :destroy



  def validation_service
    ModelValidator::P_T_Personality.new(self)
  end

  def self.factory
    Services::P_T_Personality::Factory.new
  end
  
end

