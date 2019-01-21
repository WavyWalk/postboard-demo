class AsJsonSerializer::Staff::UserSubmitted::Posts::Edit


  def initialize(post:, post_nodes: nil, post_thumbs: nil, controller:)
    @model = post
    @post_thumbs = post_thumbs
    @post_nodes = post_nodes
    @controller = controller
  end



  def success
    @model.as_json(success_options)
  end



  def error

    json = @model.as_json(methods: [:errors])

    post_nodes = @post_nodes.as_json(methods: [:errors, :node_json_er, :_tmp_id])

    post_thumbs = @post_thumbs.as_json(methods: [:errors, :node_json_er, :_tmp_id])

    json[:post_nodes] = post_nodes
    json[:post_thumbs] = post_thumbs

    json

  end

 private


 def success_options
    {
      include:
      [
        {
          author:
          {
            includes:
            [
              :au_s_id,
            ]
          }
        },
        {
          post_nodes:
          {
            methods:
            [
              :node_json
            ]
          }
        },
        {
          post_thumbs:
          {
            methods:
            [
              :node_json
            ]
          }
        },
        :post_karma,
        :post_tags,
        :post_type
      ]
    }
 end

 # def prepare_post_nodes_for_success
 #   @post_nodes = []
 #   @model.post_nodes.each do |post_node|
 #     @post_nodes << prepare_node_depending_on_type_for_success(post_node)
 #   end
 # end



 # def prepare_node_depending_on_type_for_success(post_node)
 #   node = post_node.node
 #   node.post_node_id = post_node.id
 #   case node
 #   when ::PostText
 #     node.as_json(root: true, only: [:content, :id], methods: [:post_node_id])
 #   when ::PostImage
 #     node.as_json(root: true, only: [:id, :dimensions], methods: [:post_size_url, :post_node_id])
 #   when ::PostGif
 #     node.as_json(root: true, only: [:id, :dimensions], methods: [:post_gif_url, :post_node_id])
 #    when ::VideoEmbed
 #      node.as_json(root: true, only: [:id, :link, :provider], methods: [:post_node_id])
 #   end
 # end

end
