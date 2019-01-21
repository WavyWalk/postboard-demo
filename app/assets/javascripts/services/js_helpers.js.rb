module Services
  class JsHelpers

    def self.is_element_in_viewport?(el)
      %x{
        var rect = el.getBoundingClientRect();

        return (
          rect.top >= 0 &&
          rect.left >= 0 &&
          rect.bottom <= $(window).height() &&
          rect.right <= $(window).width()
        )
      }
    end

    def self.is_element_out_of_viewport?(el)
      %x{
        var rect = el.getBoundingClientRect();

        return (
            (rect.top < 0 &&
             rect.bottom < 0) || (
             rect.top > $(window).height() &&
             rect.bottom > $(window).height()
             )
        )
      }
    end


    def self.translate_youtube_link_to_embed(link)
      `
        var regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
        var match = #{link}.match(regExp);
        var res = ''
        if (match && match[2].length == 11) {
            res = match[2];
        } else {
            res = 'error';
        }

      if (res == 'error') {
        #{return "error"}
      } else {
        #{return "//www.youtube.com/embed/#{`res`}"}
      }

      `
    end

    def self.data_url_to_blob(data_url)
      `
      var arr = #{data_url}.split(','), mime = arr[0].match(/:(.*?);/)[1],
      bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
      while(n--){
          u8arr[n] = bstr.charCodeAt(n);
      }
      #{return `new Blob([u8arr], {type:mime})`}
      `
    end

  end
end
