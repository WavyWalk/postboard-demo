class AsJsonSerializer::Staff::UserSubmitted::Post::Index

  def initialize(posts:)
    @posts = posts
    # posts.each do |post|
    #   post.post_nodes.each do |pn|
    #     pn.node.post_node_id = pn.id
    #   end
    # end
  end

  def success
    @posts.as_json(
      include:
      [
        :post_karma,

        {
          au_s_id:
          {
            include:
            [
              :uc_s_name
            ]
          }
        },

        {
          post_tags:
          {
            only:
            [
              :name
            ]
          }
        },

        {
          post_nodes:
          {
            methods: [:node_json]
          }
        }

      ]
    )
  end



end
