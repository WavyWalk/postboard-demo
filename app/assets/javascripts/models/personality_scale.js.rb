class PersonalityScale < Model
  register

  attributes :id, :post_test_id, :p_t_personality_id, :scale,
              :test_answer_variant_id

  #required for edit view, to render button dedicated to this instance, to update it.
  attr_accessor :scale_changed

  has_one :test_answer_variant, class_name: 'TestAnswerVariant'
  has_one :p_t_personality, class_name: 'P_T_Personality'


  route :update, {
    put: 'test_answer_variants/:test_answer_variant_id/personality_scales/:id'
  }, {
    defaults: [:test_answer_variant_id, :id]
  }


end
