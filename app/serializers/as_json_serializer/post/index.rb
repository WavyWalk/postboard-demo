class AsJsonSerializer::Post::Index

  def initialize(posts:)
    @posts = posts
  end

  def success

    @posts.as_json(

      include:
      [
        :discussion,
        :post_tags,
        {
          post_karma: 
          {
            include:
            [
              :pkt_cu
            ] 
          }
        },
        {
          author:
          {
            include:
            [
              :usub_with_current_user,
              :user_denormalized_stat,
              :user_karma
            ]
          }
        }

      ]
    )

  end



end
