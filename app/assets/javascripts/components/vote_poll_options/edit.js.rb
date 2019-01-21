module Components
  module VotePollOptions
    class Edit < RW
      expose
      
      include Plugins::Formable

      def get_initial_state
        vote_poll_option = n_prop(:vote_poll_option)
        {
          vote_poll_option: vote_poll_option,
          vote_poll_option_changed: false,
          image_roster: (n_prop(:image_roster) || [])
        }
      end

      def render
        t(:div, {},
          modal,
          general_errors_for(n_state(:vote_poll_option)),
          if n_state(:vote_poll_option_changed)
            t(:button, {onClick: ->{update_option}}, 'udpate')
          end,
          input(Forms::Input, n_state(:vote_poll_option), :content, 
            {
              show_name: "type what to vote about", required_field: true, 
              on_change: ->{set_vote_poll_option_changed}
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
                onClick: ->{init_image_addition}
              }, 
              'add image'
            )
          end,

          t(:button, {onClick: ->{delete_option}}, "remove this option")
        )           
      end

      def init_image_addition
        modal_open(
          nil,
          t(Components::PostImages::UploadAndPreview, 
            {
              on_image_selected: event(->(image){insert_image_to_m_content(image)}), 
              post_images: n_state(:image_roster) 
            } 
          )
        )
      end

      def insert_image_to_m_content(image)
        modal_close
        image.update_vote_poll_option_as_content(
          wilds: {vote_poll_option_id: n_state(:vote_poll_option).id}
        ).then do |u_img|
          if u_img.has_errors?
            u_img.errors.each do |er|
              n_state(:vote_poll_option).add_error(:m_content, er)
            end
          else
            n_state(:vote_poll_option).m_content = u_img
            n_state(:vote_poll_option).m_content_type = 'PostImage'
          end
          set_state(vote_poll_option: n_state(:vote_poll_option))
        end
      end

      def remove_image_from_m_content
        n_state(:vote_poll_option).m_content.remove_from_vote_poll_option(
          wilds: {vote_poll_option_id: n_state(:vote_poll_option).id}
        ).then do |image|
          if image.has_errors?
            image.errors.each do |er|
              n_state(:vote_poll_option).add_error(:m_content, er)
            end
          else
            n_state(:vote_poll_option).m_content = nil
            n_state(:vote_poll_option).m_content_type = nil
          end
          set_state vote_poll_option: n_state(:vote_poll_option)
        end
      end

      def set_vote_poll_option_changed
        unless n_state(:vote_poll_option_changed)
          set_state vote_poll_option_changed: true
        end
      end

      def update_option
        collect_inputs
        n_state(:vote_poll_option).update.then do |vote_poll_option|
          if vote_poll_option.has_errors?            
            set_state({vote_poll_option: vote_poll_option})
          else
            set_state({vote_poll_option: vote_poll_option, vote_poll_option_changed: false})
          end
        end
      end

      def delete_option
        n_state(:vote_poll_option).destroy.then do |vote_poll_option|
          if vote_poll_option.has_errors?
            n_state(:vote_poll_option).errors = vote_poll_option.errors
            force_update
          else
            emit(:on_delete)
          end
        end
      end

    end
  end
end