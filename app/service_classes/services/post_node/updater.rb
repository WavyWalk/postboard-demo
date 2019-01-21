class Services::PostNode::Updater

  def initialize(owner)
    @owner = owner
  end

  def try_update_tsv!
    if @owner.node_type == 'PostText'
      ptsv = Services::PostTsv.initialize_post_tsv(model: @owner.node, post_id: @owner.post_id)
      ptsv.save!
    end
  end

  def try_destroy_tsv!
    # if @owner.node_type == 'PostText'
    #   Services::PostTsv.destroy_tsv!(model: @owner.node, post_id: @owner.post_id)
    # end
  end

end