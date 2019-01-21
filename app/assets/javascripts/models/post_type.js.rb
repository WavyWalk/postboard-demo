class PostType < Model

  register

  attributes :id, :name, :alt_name

  has_one :post, class_name: "Post"

  has_one :post_type_link, class_name: 'PostTypeLink'

  def self.url_for_feed
    "/api/post_types/feed"
  end

end
