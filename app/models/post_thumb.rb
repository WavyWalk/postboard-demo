class PostThumb < ActiveRecord::Base

  belongs_to :node, polymorphic: true
  belongs_to :post

  validates_associated :node

  attr_accessor :_tmp_id, :_changed, :_should_destroy



  def arbitrary
    @_arbitrary ||= {}
  end


  #method is used in as_json e.g. includes: {post_thumbs: {methods: [:node_json]}} : will be used for restricting fields showable to users 
 
  def node_json
    self.node.json_for_thumb
  end



  def node_json_er
    self.node.json_for_post_node_er
  end



  def self.factory
    ::Services::PostThumb::Factory
  end


  def composer_helper
    @composer_helper ||= Services::PostThumb::ComposerHelper.new(self)
  end


end
