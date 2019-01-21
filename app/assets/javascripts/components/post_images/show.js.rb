module Components
  module PostImages
    class Show < RW
      expose

      #PROPS
      #REQUIRED:
      # :post_image : PostImage < Model
      # css_class
      #OPTIONAL


      def validate_props
        if !props.post_image || !props.post_image.is_a?(PostImage)
          puts "#{self} of #{self.class}: required_prop :post_image : PostImage was not passed -> got #{props.post_image} of #{props.post_image.class} instead"
        end
      end

      def get_initial_state
        width = 600
        height = 600
        if n_prop(:post_image)
          width, height = self.props.post_image.dimensions.split('x')
        end
        {
          width: width,
          height: height
        }
      end

      def render
        t(:div, {className: "post-image-show #{n_prop(:css_class)}"},
          if n_prop(:post_image)
            [
            t(:div, {},
              t(:img, 
                {
                  src: n_prop(:post_image).post_size_url, 
                  className: 'img-responsive', 
                  alt: n_prop(:post_image).alt_text
                }
              )
            ),
            if n_prop(:show_source) && n_prop(:post_image).source_name
              t(:div, {className: 'sourceDisclaimer'},
                n_prop(:post_image).source_name
              )
            end
            ]
          end
        )
      end

    end
  end
end
