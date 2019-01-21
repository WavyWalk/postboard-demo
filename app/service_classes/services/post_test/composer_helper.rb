class Services::PostTest::ComposerHelper

  class << self

    def update_or_initialize_with_error_when_added_to_post(attributes_hash:)
      post_test = ::PostTest.qo
                          .find_first_by_id( attributes_hash[:id] )
                          .get_result

      if post_test

        unless post_test.updater.update_when_added_to_post(attributes_hash)

          post_test.add_custom_error('something is wrong with post test try adding new one')

        end

      else

        post_test = ::PostTest.factory
                      .builder(attributes: attributes_hash)
                      .add_custom_error(:general, 'something is wrong with vote poll ')
                      .get_result

      end

      post_test

    end

    def update_or_initialize_personality_test_with_error_when_added_to_post(attributes_hash:)
      post_test = ::PostTest.qo
        .find_first_by_id( attributes_hash[:id] )
        .get_result

      if post_test

      else
        post_test = ::PostTest.factory
                      .builder(attributes: attributes_hash)
                      .add_custom_error(:general, 'something is wrong with vote poll ')
                      .get_result
        post_test.is_personality = true
      end

      post_test
    end

  end

end
