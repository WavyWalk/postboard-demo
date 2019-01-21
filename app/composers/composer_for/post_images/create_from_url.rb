class ComposerFor::PostImages::CreateFromUrl < ComposerFor::Base

  def initialize(controller, params)
    @params = params
    @controller = controller
  end

  def before_compose
    set_proxy_image
  end

  def set_proxy_image
    @proxy_image = FromUrlProxyImage.new
    @proxy_image.user_id = @controller.current_user.id
    @proxy_image.file = @params['url']
  end

  def compose
    @proxy_image.save!
  end

  def after_composer
    #TODO: set bnackground job to delete image
  end

  def resolve_success
    publish(:ok, @proxy_image)
  end

  def resolve_fail(e)

    case e
    when e
      raise e
    else
      raise e
    end

  end

end
