class PersonalityScale < ActiveRecord::Base

  include ModelValidator::CustomErrorable
  
  belongs_to :p_t_personality, class_name: :P_T_Personality
  belongs_to :test_answer_variant


  def self.factory
    Services::PersonalityScale::Factory
  end

  def validation_service
    ModelValidator::PersonalityScale.new(self)
  end

end
