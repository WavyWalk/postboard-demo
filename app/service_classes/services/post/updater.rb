class Services::Post::Updater




  def initialize(owner)
    @owner = owner
  end


  def update_when_staff_edit(attributes)
    @owner.title = attributes[:title]
  end


  def concat_repeating_post_text_nodes_content_and_remove_unnecessary

    post_nodes_length = @owner.post_nodes.length

    to_remove = []

    @owner.post_nodes.each_with_index do |post_node, index|

      break if post_nodes_length == (index + 1)

      first = post_node

      second = @owner.post_nodes[index+1]

      if (first.node_type == 'PostText') && (second.node_type == 'PostText')

        text = first.node.content + second.node.content
        second.node.content = text
        first.node.content = nil

        if !second.node.id
          second.node.id = first.node.id
        end

      end

    end

    @owner.post_nodes = @owner.post_nodes.reject do |post_node|
      post_node.node.is_a?(::PostText) && post_node.node.content == nil
    end


  end


  def self.concat_repeating_post_text_nodes_content_and_remove_unnecessary_from_collection(collection)

    post_nodes_length = collection.length

    collection.each_with_index do |post_node, index|

      break if post_nodes_length == (index + 1)

      first = post_node

      second = collection[index+1]

      if (first.node_type == 'PostText') && (second.node_type == 'PostText')

        text = first.node.content + second.node.content
        second.node.content = text
        first.node.content = nil
        first.arbitrary[:delete] = true

        if !second.node.id
          second.node.id = first.node.id
        end

      end

    end

    collection.delete_if do |post_node|
      true if post_node.arbitrary[:delete]
    end

  end



  def update_post_tags(attributes)

    to_destroy = []
    to_add = []

    assigned_post_tags = @owner.post_tags

    attributes ||= []

    attributes.each do |pt_attributes|

      if pt_attributes[:id] && pt_attributes[:_should_destroy]
        to_destroy << pt_attributes[:id]

      else
        if id = pt_attributes[:id]
          if assigned_post_tags.find {|pn| pn.id == id }
            next
          else
            to_add << pt_attributes
          end
        else
          to_add << pt_attributes
        end
      end
    end

    to_destroy = ::PostTag.joins(:post_tag_links).where('post_tags.id in (?) and post_tag_links.post_id = ?', to_destroy, @owner.id)

    @owner.post_tags.delete(to_destroy)

    to_add = ::PostTag.factory.create_collection_for_post_create( to_add )

    @owner.post_tags << to_add

  end


  def build_and_persist_nodes_order!
    ids = @owner.post_nodes.map(&:id)
    @owner.nodes_order = ids
    @owner.save!
  end

  def build_and_persist_s_nodes(post_nodes = @owner.post_nodes)
    s_nodes = []

    post_nodes.each do |post_node|

      case post_node.node

      when ::PostImage
        s_nodes << post_node.as_json(include: [{node: {methods: [:base_url]}}])
      
      when ::PostGif
        s_nodes << post_node.as_json(include: [{node: {methods: [:base_url]}}])
      
      when ::PostVotePoll
        s_nodes << post_node.as_json(
          include: [
            node: {
              include: [ 
                {m_content: {methods: [:base_url]}}, 
                {vote_poll_options: {include: [:m_content]}}
              ]
            }
          ]
        )

      when ::PostTest
        if post_node.node.is_personality
          json_node = post_node.as_json
          json_node['node'] = AsJsonSerializer::PersonalityTests::Show.new(post_node.node).success
          s_nodes << json_node
          byebug
        else
          json_node = post_node.as_json
          json_node['node'] = AsJsonSerializer::PostTests::Create.new(post_node.node).success
          s_nodes << json_node
        end

      when ::MediaStory
        media_story_json = ::AsJsonSerializer::MediaStories::Create.new(post_node.node).success
        post_node_json = post_node.as_json
        post_node_json['node'] = media_story_json
        s_nodes << post_node_json
      else
        s_nodes << post_node.as_json(include: [:node])
      end
    end

    @owner.s_nodes = s_nodes.to_json
    @owner.save!

  end

  def build_post_nodes_order
    ids = @owner.post_nodes.map(&:id)
    @owner.nodes_order = ids
  end


  def update_tsv!
    ptsv = ::Services::PostTsv.initialize_post_tsv(model: @owner, post_id: @owner.id)
    ptsv.save!
  end

  def modify_s_node_post_test_and_save(post_test)
    parsed_s_nodes = JSON.parse(@owner.s_nodes)
    if parsed_s_nodes.is_a?(Array)
      found = false
      parsed_s_nodes.each do |post_node|
        if post_node['node_type'] == 'PostTest'
          if (x =  post_node['node'])['id'] == post_test.id
            post_node['node'] = post_test.as_json
          else
            nil
          end 
        end
      end
    end
    @owner.s_nodes = parsed_s_nodes.to_json
    @owner.save!
  end

end
