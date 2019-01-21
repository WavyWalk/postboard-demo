class AsJsonSerializer::Post::Create




  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end





  def success

    @model.as_json({
      include:
      [
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
        :post_type,
        :post_tags
      ]
    })
    # prepare_post_nodes_for_success
    #
    # {post_nodes: @post_nodes, id: @model.id}

  end





  def error

    @model.as_json({
      methods: [:errors],
      include:
      [
        {
          post_nodes:
          {
            methods:
            [
              :node_json_er
            ]
          }
        },
        {
          post_thumbs:
          {
            methods:
            [
              :node_json_er
            ]
          }
        },
        post_tags:
        {
          methods: [:errors]
        },
        post_type:
        {
          methods: [:errors] 
        }
      ]
    })

  end




end
