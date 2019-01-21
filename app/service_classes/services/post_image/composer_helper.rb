class Services::PostImage::ComposerHelper

  class << self

    def update_or_initialize_with_error_when_added_to_post(attributes_hash:)
      post_image = ::PostImage.qo
                              .find_first_by_id(attributes_hash[:id])
                              .get_result

      if post_image

        post_image.updater.update_when_added_to_post(attributes_hash)

        unless post_image.save
          post_image.add_custom_error('something is wrong with image try reuploading')
        end

      else

        post_image = ::PostImage.factory
                                .builder(attributes: attributes_hash)
                                .add_custom_error(:general, 'such image could not be found try uploading new')
                                .get_result

      end

      post_image

    end

  end

end
