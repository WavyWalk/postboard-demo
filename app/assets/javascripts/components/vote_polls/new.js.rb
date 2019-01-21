module Components
  module VotePolls
    class New < RW
      expose

      include Plugins::Formable

      def validate_props
        #on_done : ProcEvent |vote_poll : PostVotePoll| #required
      end

      def get_initial_state
        vote_poll = n_prop(:vote_poll) ? n_prop(:vote_poll) : PostVotePoll.new 
        {
          vote_poll: vote_poll,
          image_roster: [],
        }
      end

      def render
        t(:div, {className: 'VotePolls-New'},
          modal,
          t(:div, {className: 'question'},
            input(Forms::Input, n_state(:vote_poll), 
              :question, 
              {
                show_name: "enter vote question", required_field: true
              }
            ),

            t(:div, {className: 'mContent'}, 
              if n_state(:vote_poll).m_content && n_state(:vote_poll).m_content_type == 'PostImage'
                [
                  t(Components::PostImages::Show, {post_image: n_state(:vote_poll).m_content}),
                  t(:div, {className: 'btn btn-group'},
                    t(:button, {onClick: ->{remove_image_from_vote_poll}, className: 'btn btn-sm'}, 'remove image')
                  )
                ]
              else
                t(:div, {className: 'btn-group'},
                  t(:button, 
                    { 
                      onClick: ->{init_image_addition_to_vote_poll},
                      className: 'btn btn-sm'
                    },
                    'add image'
                  )
                )
              end
            )
          ),
          
          n_state(:vote_poll).vote_poll_options.map do |vote_poll_option|
            t(:div, {className: 'option'},
              input(Forms::Input, vote_poll_option, :content, {show_name: "type what to vote about", required_field: true}),
              t(:div, {className: 'm_content'},
                if vote_poll_option.m_content && vote_poll_option.m_content_type == 'PostImage'
                  [
                    t(Components::PostImages::Show, {post_image: vote_poll_option.m_content}),
                    t(:div, {className: 'btn-group'},
                      t(:button, {onClick: ->{remove_image_from_vote_poll_option(vote_poll_option)}, className: 'btn btn-sm'}, 'remove image')
                    )
                  ]
                else
                  t(:div, {className: 'btn-group'},
                    t(:button, 
                      { 
                        className: 'btn btn-sm',
                        onClick: ->{init_image_addition_to_vote_poll_option(vote_poll_option)}
                      }, 
                      'add image'
                    )
                  )
                end
              ),
              t(:div, {className: 'btn-group'},
                t(:button, {onClick: ->{delete_option(vote_poll_option)}, className: 'btn btn-sm'}, "remove")
              )
            )           
          end,

          t(:div, {className: 'btn btn-group'},
            t(:button, {onClick: ->{add_option}, className: 'btn btn-sm btn-primary addOption-btn'}, "add vote option")
          ),

          t(:div, {className: 'btn-group'},
            t(:button, {onClick: ->{done}, className: 'btn btn-sm'}, "OK"),
            t(:button, {onClick: ->{cancel}, className: 'btn btn-sm'}, "cancel")
          )
        )
      end


      def init_image_addition_to_vote_poll_option(vote_poll_option)
        modal_open(
          nil,
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_image_to_vote_poll_option(image, vote_poll_option)}), 
              post_images: n_state(:image_roster) 
            } 
          )
        )
      end

      def insert_image_to_vote_poll_option(image, vote_poll_option)
        modal_close
        vote_poll_option.m_content = image
        vote_poll_option.m_content_type = 'PostImage'
        set_state vote_poll: n_state(:vote_poll)
      end

      def remove_image_from_vote_poll_option(vote_poll_option)
        vote_poll_option.m_content = nil
        vote_poll_option.m_content_type = nil
        set_state vote_poll: n_state(:vote_poll)
      end

      def init_image_addition_to_vote_poll
        modal_open(
          nil,
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_image_to_vote_poll(image)}), 
              post_images: n_state(:image_roster) 
            } 
          )
        )
      end

      def insert_image_to_vote_poll(image)
        modal_close
        n_state(:vote_poll).m_content = image
        n_state(:vote_poll).m_content_type = 'PostImage'
        set_state vote_poll: n_state(:vote_poll)
      end

      def remove_image_from_vote_poll
        n_state(:vote_poll).m_content = nil
        n_state(:vote_poll).m_content_type = nil
        set_state vote_poll: n_state(:vote_poll)
      end

      def add_option
        vote_poll = n_state(:vote_poll)
        new_option = VotePollOption.new
        vote_poll.vote_poll_options << new_option
        set_state vote_poll: n_state(:vote_poll)
      end

      def delete_option(vote_option)
        n_state(:vote_poll).vote_poll_options.data.delete(vote_option)
        set_state vote_poll: n_state(:vote_poll)
      end

      def done
        collect_inputs(form_model: :vote_poll)
        n_state(:vote_poll).create.then do |vote_poll|
          if vote_poll.has_errors?
            set_state vote_poll: vote_poll
          else
            if n_prop(:on_collect)
              n_prop(:on_collect).call(vote_poll, self)                
            end
            emit(:on_done, vote_poll)
          end
        end
        # unless n_state(:vote_poll).has_errors?
        #   emit(:on_done, n_state(:vote_poll))
        # else
        #   set_state vote_poll: n_state(:vote_poll)
        # end
      end

      def cancel
        emit(:on_cancel)
      end

    end
  end
end