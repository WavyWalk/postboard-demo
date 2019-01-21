class Services::PostGif::Updater



  def initialize(owner)
    @owner = owner
  end



  def update_when_added_to_post(attributes)
    if @owner.orphaned != false
      @owner.orphaned = false
      @owner.save
    else
      @owner
    end
  end



  def when_post_staff_update(attributes)
    @owner.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end



end
