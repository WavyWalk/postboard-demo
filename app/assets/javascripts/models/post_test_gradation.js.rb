class PostTestGradation < Model
  register

  attributes :id, :from, :to, :message, :content_type, :post_test_id, :content_id, :content_type

  has_one :post_test, class_name: 'PostTest'
  has_one :content, polymorphic_type: :content_type, aliases: [:s_content_json]

  route :create, post: 'post_tests/:post_test_id/post_test_gradations'
  route :update, {put: 'post_tests/:post_test_id/post_test_gradations/:id'}, {defaults: [:id, :post_test_id]}
  route :destroy, {delete: 'post_test_gradations/:id'}, {defaults: [:id]}

end