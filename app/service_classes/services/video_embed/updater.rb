class Services::VideoEmbed::Updater
  
  def initialize(owner)
    @owner = owner    
  end  

  def assign_provider_depending_on_link
    provider =  case @owner.link
                when @owner.class::YOUTUBE_REGEX
                  'youtube'
                else
                  nil
                end

    if provider
      @owner.provider = provider
    else
      nil
    end
  end 


  def when_post_staff_update(attributes)
    @owner.link = attributes[:link]
    assign_provider_depending_on_link
    @owner
  end
  
end
