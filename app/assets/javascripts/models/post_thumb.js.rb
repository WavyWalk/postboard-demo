class PostThumb < Model

  register

  has_one :node, polymorphic_type: 'node_type', aliases: [:node_json, :node_json_er]

  attributes :id


end
