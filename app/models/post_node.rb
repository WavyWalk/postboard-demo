class PostNode < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :post, inverse_of: :post_nodes
  belongs_to :node, polymorphic: true
  #END #ASSOCIATIONS
  validates_associated :node

  attr_accessor :_tmp_id, :_changed, :_should_destroy


  def arbitrary
    @_arbitrary ||= {}
  end

  def composer_helper
    @composer_helper ||= Services::PostNode::ComposerHelper.new(self)
  end

  def node_with_json_root
    node.as_json(root: true)
  end

  # =>    SERVICE ACCESSORS

  def self.factory
    Services::PostNode::Factory
  end

  def updater
    @udpater ||= Services::PostNode::Updater.new(self)
  end

  # =>    SERVICE ACCESSORS

  def node_json
    self.node.json_for_post_node
  end

  def node_json_er
    self.node.json_for_post_node_er
  end


  def serialize_as_json_for_s_node
    case self.node

    when ::PostText
      self.as_json(include: [:node])

    when ::PostImage
      self.as_json(include: [{node: {methods: [:base_url]}}])

    when ::VideoEmbed
      self.as_json(include: [:node])

    when ::PostGif
      self.as_json(include: [{node: {methods: [:base_url]}}])
    
    when ::PostVotePoll
      self.as_json(
        include: [
          node: {
            include: [ 
              {m_content: {methods: [:base_url]}}, 
              {vote_poll_options: {include: {m_content: {methods: [:base_url]}}}}
            ]
          }
        ]
      )

    when ::PostTest
      if self.node.is_personality
        json_node = self.as_json
        json_node['node'] = AsJsonSerializer::PersonalityTests::Show.new(self.node).success
        json_node

      else
        json_node = self.as_json
        json_node['node'] = AsJsonSerializer::PostTests::Create.new(self.node).success
        json_node
      end

    when ::MediaStory
      media_story_json = ::AsJsonSerializer::MediaStories::Create.new(self.node).success
      post_node_json = self.as_json
      post_node_json['node'] = media_story_json
      post_node_json
    else
      raise "unreachable condition reached at #{self.class.name}#"
      #post_node.as_json(include: [:node])
    
    end
  end

end
