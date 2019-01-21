class Services::PostGif::ComposerHelper

  class << self

    def update_or_initialize_with_error_when_added_to_post(attributes_hash:)
      post_gif = ::PostGif.qo
                          .find_first_by_id( attributes_hash[:id] )
                          .get_result

      if post_gif

        unless post_gif.updater_service.update_when_added_to_post(attributes_hash)

          post_gif.add_custom_error('something is wrong with gif try reuploading')

        end

      else

        post_gif = ::PostGif.factory
                            .builder(attributes: attributes_hash)
                            .add_custom_error(:general, 'such gif could not be found try uploading new')
                            .get_result

      end

      post_gif

    end

  end

end
