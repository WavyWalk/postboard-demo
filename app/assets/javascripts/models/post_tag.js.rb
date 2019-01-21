class PostTag < Model

  register

  attributes :id, :name

  has_many :posts, class_name: 'Post'

  has_many :post_tag_links, class_name: 'PostTagLink'

end
