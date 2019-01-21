class Services::PostNode::ComposerHelper

  def initialize(owner)
    @owner = owner
  end

  def update_node_for_staff_update(attributes)
    @owner.node.updater.when_post_staff_update(attributes)
    @owner
  end

end
