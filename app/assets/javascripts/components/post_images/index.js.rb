module Components
  module PostImages
    class Index < RW
      expose

      #PRPOS
      #OPTIONAL
      # :on_image_selected : ProcEvent (post_image : PostImage);
      # used for inserting image to WysiTextarea
      def get_initial_state
        {
          #post_images: ModelCollection.new
        }
      end

      def render
        post_images_roster = n_prop(:post_images) || []

        t(:div, {className: 'post-image-roster'},
          post_images_roster.map do |post_image|
            t(:div, {className: 'wrapped-img'},
              t(:img, {src: "#{post_image.post_size_url}"}),
              t(:button, {onClick: ->{ insert_image(post_image) }}, 'insert this image')
            )
          end
        )
      end
      #
      # def add_image(image)
      #
      #   state.post_images << image
      #   set_state post_images: state.post_images
      #
      # end

      def insert_image(post_image)
        post_image.attributes.delete(:file)
        emit(:on_image_selected, post_image)
      end

    end
  end
end
