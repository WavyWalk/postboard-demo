class AsJsonSerializer::Post::Show

  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end


  def success

    @model.as_json(success_options)

  end

 private

  def success_options
    {
      include:
      [
        {
          au_s_id:
          {
            include:
            [
              :uc_s_name,
            ]
          }
        },
        {
          post_karma: 
          {
            include: 
            [
              :pkt_cu
            ]
          }
        },
        :post_tags
      ]
    }
  end


  def prepare_node_depending_on_type_for_success(node)
    case node
    when ::PostText
      node.as_json(root: true, only: [:content, :id])
    when ::PostImage
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_size_url])
    when ::PostGif
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_gif_url])
    when ::VideoEmbed
      node.as_json(only: [:id, :link, :provider], root: true)
    end
  end

end
