class Services::PostImage::Updater

  def initialize(owner)
    @owner = owner
  end

  def update_when_added_to_post(attributes)
    if @owner.orphaned != false
      @owner.orphaned = false
    end
    @owner
  end

  def when_post_staff_update(attributes)
    ::PostImage.composer_helper.update_or_initialize_with_error_when_added_to_post(attributes_hash: attributes)
  end

  def assign_file_url
    @owner.file_url = @owner.file.url
    self
  end

end
