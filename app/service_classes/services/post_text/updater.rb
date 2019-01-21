class Services::PostText::Updater

  def initialize(owner)
    @owner = owner
  end

  def when_post_staff_update(attributes)
    
    @owner.content = Services::PostTextSanitizer.sanitize_post_text_content(attributes[:content])
    
  end

end
