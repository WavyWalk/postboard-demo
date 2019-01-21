class Services::PostVotePoll::ComposerHelper

  class << self

    def update_or_initialize_with_error_when_added_to_post(attributes_hash:)
      post_vote_poll = ::PostVotePoll.qo
                          .find_first_by_id( attributes_hash[:id] )
                          .get_result

      if post_vote_poll

        unless post_vote_poll.updater_service.update_when_added_to_post(attributes_hash)

          post_vote_poll.add_custom_error('something is wrong with vote poll try adding new one')

        end

      else

        post_vote_poll = ::PostVotePoll.factory
                            .builder(attributes: attributes_hash)
                            .add_custom_error(:general, 'something is wrong with vote poll ')
                            .get_result

      end

      post_vote_poll

    end

  end

end
