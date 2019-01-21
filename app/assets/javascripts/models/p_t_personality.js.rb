class P_T_Personality < Model
  register

  attributes :id, :title, :post_test_id, :media_type, :media_id

  has_one :post_test, class_name: 'PostTest'
  has_one :media, polymorphic_type: :media_type
  has_many :personality_scales, class_name: 'PersonalityScale'

  route :create, {
    post: "personality_tests/:post_test_id/p_t_personalities"
  }, {
    defaults: [:post_test_id]
  } 

  route :destroy, {
    delete: "personality_tests/:post_test_id/p_t_personalities/:id"
  }, {
    defaults: [:post_test_id, :id] 
  }

  route :update, {
    put: "personality_tests/:post_test_id/p_t_personalities/:id"
  }, {
    defaults: [:post_test_id, :id]  
  }

  route :medias_update, {
    post: "p_t_personalities/:id/medias"
  }, {
    defaults: [:id]
  }

  def before_route_medias_update(r)
    before_route_update(r)
  end

  def after_route_medias_update(r)
    after_route_update(r)
  end

end