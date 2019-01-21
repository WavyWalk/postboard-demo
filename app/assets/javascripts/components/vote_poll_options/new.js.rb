module Components
  module VotePollOptions
    class New < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          vote_poll_option: n_prop(:vote_poll_option),
          image_roster: []
        }
      end

      def render
        t(:div, {className: 'VotePollOptions-New'},
          modal,
          input(Forms::Input, n_state(:vote_poll_option), :content, 
            {
              show_name: "type what to vote about", required_field: true
            }
          ),

          if n_state(:vote_poll_option).m_content && n_state(:vote_poll_option).m_content_type == 'PostImage'
            [
              t(Components::PostImages::Show, {post_image: n_state(:vote_poll_option).m_content}),
              t(:button, {onClick: ->{remove_image_from_m_content}}, 'remove image')
            ]
          else
            t(:button, 
              { 
                onClick: ->{init_image_addition},
                className: 'btn btn-sm'
              }, 
              'add image'
            )
          end,

          if n_prop(:save_in_place)
            t(:button, {onClick: ->{submit_when_save_in_place}}, "save")
          else
            t(:button, {onClick: ->{delete_option}}, "remove this option")
          end
        )
      end

      def init_image_addition
        modal_open(
          nil,
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_image(image)}), 
              post_images: n_state(:image_roster) 
            } 
          )
        )
      end

      def insert_image(image)
        modal_close
        n_state(:vote_poll_option).m_content = image 
        n_state(:vote_poll_option).m_content_type = 'PostImage'
        set_state vote_poll_option: n_state(:vote_poll_option)
      end

      def remove_image_from_m_content
        n_state(:vote_poll_option).m_content = nil
        n_state(:vote_poll_option).m_content_type = nil
        #n_state(:variant).question_type = nil
        set_state vote_poll_option: n_state(:vote_poll_option)
      end

      def submit_when_save_in_place
        collect_inputs
        n_state(:vote_poll_option).create(
          wilds: {
            post_vote_poll_id: n_prop(:owner).n_state(:vote_poll).id
          }
        ).then do |vote_poll_option|
          if vote_poll_option.has_errors?
            set_state vote_poll_option: vote_poll_option
          else
            emit(:on_done, vote_poll_option)
          end
        end
      end


    end
  end
end