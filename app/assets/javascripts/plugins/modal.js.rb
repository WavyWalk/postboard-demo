module Plugins
  module Modal


    def modal(options = {}, passed_children = `null`)
      options[:ref] = "modal"
      t(Components::Shared::Modal, options,
        passed_children
      )
    end

    def modal_instance
        ref(:modal).rb
    end

    def modal_open(head_content = false, content = false, on_close = false)
      modal_instance.open(head_content, content, on_close)
    end

    def modal_close(preserve = false)
      modal_instance.close(preserve)
    end

    

  end
end
