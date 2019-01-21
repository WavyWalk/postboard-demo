class PostText < Model

  register

  attributes :id, :content, :post_node_id

  route :update, {put: "post_texts/:id"}, {defaults: [:id]}

  route :destroy, {delete: "post_texts/:id"}, {defaults: [:id]}

  route :create, {post: "post_texts"}

end
