class HTTP
  def send(method, url, options, block)
    @method   = method
    @url      = url
    @payload  = options.delete :payload
    @handler  = block

    @settings.update options

    settings, payload = @settings.to_n, @payload

    %x{
      if (#{@method == "get" && @payload != nil}) {
        payload = #{@payload.to_n};
        #{settings}.data = $.param(payload);
      }
      else if (typeof(#{payload}) === 'string') {
        #{settings}.data = payload;
      }
      else if (payload != nil) {
        settings.data = payload.$to_json();
        settings.contentType = 'application/json';
      }
      settings.url  = #@url;
      settings.type = #{@method.upcase};
      settings.success = function(data, status, xhr) {
        return #{ succeed `data`, `status`, `xhr` };
      };
      settings.error = function(xhr, status, error) {
        return #{ fail `xhr`, `status`, `error` };
      };

      settings.xhr = function(){
        // get the native XmlHttpRequest object
        var xhr = $.ajaxSettings.xhr() ;

        //Added functinality for adding on progress handler if option[:on_progress] : Proc | Object responding to call
        //can be used for e.g. file uploading progress
        #{

          if options[:on_progress]

            `xhr.upload.onprogress = function(evt){
              #{options[:on_progress].call(`evt`)}
              //console.log('progress', evt.loaded/evt.total*100)
            };`

          end

        }

        // return the customized object
        return xhr ;
    }

      $.ajax(settings);
    }

    @handler ? self : promise
  end
end
