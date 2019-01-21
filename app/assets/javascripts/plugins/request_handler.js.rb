module Plugins

  module RequestHandler

    def defaults_on_response
      authorize!

      if @component && @component.progress_bar_instance
        @component.progress_bar_instance.off
      end
      if @response.status_code == 404
        $HISTORY.pushState(nil, "/error404")
      elsif @response.status_code == 500
        $HISTORY.pushState(nil, "/er505?status_code=500")
      elsif @response.status_code == 400
        $HISTORY.pushState(nil, "/er505?status_code=400")
      end
    end

    def defaults_before_request
      if @component && @component.progress_bar_instance
        (@component.progress_bar_instance.on if @component.has_progress_bar)
      end 
    end

    def authorize!
      #obvious
      if @response.status_code == 403
        $HISTORY.replaceState(nil, "/forbidden")
      end
    end

  end

end
