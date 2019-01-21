module Plugins

  module ReactRouter

    def link_to(body, link, options = {})
     if block_given?
      body = yield
     end
      t(`ReactRouter.Link`, {to: link, query: options.to_n, className: options[:className]}, body)    
    end

  end

end