module Components
  module PostImages
    class UploadAndPreview < RW
      expose

      def validate_props

      end

      def render
        t(:div, {},
          t(:p, {}, 'you can upload images many times for them to be later used'),
          t(Components::PostImages::Index, {ref: 'index', on_image_selected: n_prop(:on_image_selected), post_images: n_prop(:post_images)}),
          t(Components::PostImages::New, {
                                         ref: 'new',
                                         on_image_uploaded: event(->(image){on_image_uploaded(image)})
                                        }
          )
        )
      end

      def on_image_uploaded(image)
        if n_prop(:post_images)
          n_prop(:post_images) << image
          force_update
        end
      end

    end
  end
end
