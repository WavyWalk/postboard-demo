class PostTagLink < Model

  register

  attributes :id, :post_id, :post_tag_id

  has_one :post, class_name: 'Post'

  has_one :post_tag, class_name: 'PostTag'

end
