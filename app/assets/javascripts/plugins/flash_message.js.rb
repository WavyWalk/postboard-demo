module Plugins

  module FlashMessage
  
    def create_flash(message)
      msg = Shared::Flash::Message.new(t(:div, {}, message))
      Components::App::Main.instance.ref(:flash).rb.add_message(msg)
    end
  
  end

end