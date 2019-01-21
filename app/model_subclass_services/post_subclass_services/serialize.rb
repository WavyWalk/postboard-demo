class PostSubclassServices::Serialize





  def initialize(owner)
    @owner = owner
  end






  def post_nodes_serialized
    ar = []

    @owner.post_nodes.each do |pn|
       ar << serialize_node_depending_on_type(pn)
    end

    ar
  end






  def serialize_node_depending_on_type(post_node)
    node = post_node.node
    node.post_node_id = post_node.id
    case node
    when PostText
      node.as_json(root: true, only: [:content, :id], methods: [:post_node_id])
    when PostImage
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_size_url, :post_node_id])
    when PostGif
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_gif_url, :post_node_id])
    when VideoEmbed
      node.as_json(root: true, only: [:id, :link, :provider], methods: [:post_gif_url, :post_node_id])
    end
  end







  def post_nodes_with_root_and_errors_and_tmp_ids
    ar = []

    @owner.post_nodes.each do |pn|
       ar << serialize_node_depending_on_type_with_errors_and_post_node_id_with_tmp_id(pn)
    end

    ar
  end






  def serialize_node_depending_on_type_with_errors_and_post_node_id(post_node)
    #post_node.serialize_service.for_post_show
    # json_to_return = @owner.as_json(root: true, methods: [:post_node_id])
    # json_to_return[:tmp_id] = @owner.arbitrary[:tmp_id]
    # json_to_return[:post_node_id] = @owner.post_node_id
    # json_to_return
    node = post_node.node
    node.post_node_id = node.id
    case node
    when PostText
      node.as_json(root: true, only: [:content, :id], methods: [:post_node_id, :errors])
    when PostImage
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_size_url, :post_node_id, :errors])
    when PostGif
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_gif_url, :post_node_id, :errors])
    when VideoEmbed
      node.as_json(only: [:id, :link, :provider], methods: [:errors], root: true)
    end
  end






  def serialize_node_depending_on_type_with_errors_and_post_node_id_with_tmp_id(post_node)
    #post_node.serialize_service.for_post_update_error
    # json_to_return = @owner.as_json(root: true, methods: [:post_node_id])
    # json_to_return[:tmp_id] = @owner.arbitrary[:tmp_id]
    # json_to_return[:post_node_id] = @owner.post_node_id
    # json_to_return

    node = post_node.node
    node.post_node_id = node.id
    case node
    when PostText
      node.as_json(root: true, only: [:content, :id], methods: [:post_node_id, :errors, :_tmp_id])
    when PostImage
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_size_url, :post_node_id, :errors, :_tmp_id])
    when PostGif
      node.as_json(root: true, only: [:id, :dimensions], methods: [:post_gif_url, :post_node_id, :errors, :_tmp_id])
    when VideoEmbed
      node.as_json(root: true, only: [:id, :link, :provider], methods: [:errors, :_tmp_id, :post_node_id])
    end
  end



end
