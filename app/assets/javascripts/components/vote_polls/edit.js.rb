module Components
  module VotePolls
    class Edit < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          vote_poll: false,
          vote_poll_changed: false,
          image_roster: []
        }
      end

      def component_did_mount
        
        PostVotePoll.show(wilds: {id: n_prop(:vote_poll).id}).then do |vote_poll|
          begin
          set_state vote_poll: vote_poll
          rescue Exception => e
            p e
          end
        end
        
      end

      def render
        t(:div, {},
          if n_state(:vote_poll)
            t(:div, {},
              modal,

              if n_state(:vote_poll_changed)
                t(:button, {onClick: ->{update_vote_poll}}, 'update')
              end,
              input(Forms::Input, n_state(:vote_poll), 
                :question, 
                {
                  show_name: "enter vote question", required_field: true,
                  on_change: ->{set_vote_poll_changed}
                }
              ),

              if ers = n_state(:vote_poll).errors[:m_content]
                ers.map do |er|
                  t(:p, {}, "image: #{er}")
                end
              end,

              if n_state(:vote_poll).m_content && n_state(:vote_poll).m_content_type == 'PostImage'
                [
                  t(Components::PostImages::Show, {post_image: n_state(:vote_poll).m_content}),
                  t(:button, {onClick: ->{remove_image_from_vote_poll}}, 'remove image')
                ]
              else
                t(:button, 
                  { 
                    onClick: ->{init_image_addition_to_vote_poll}
                  },
                  'add image'
                )
              end,

              n_state(:vote_poll).vote_poll_options.data.map do |vote_poll_option|
                t(Components::VotePollOptions::Edit, 
                  {
                    key: "#{vote_poll_option}",
                    vote_poll_option: vote_poll_option,
                    on_delete: event(->{delete_option(vote_poll_option)})
                  }
                )
              end,

              t(:button, {onClick: ->{init_option_addition}}, "add vote option"),


              t(:button, {onClick: ->{done}}, "OK"),
              t(:button, {onClick: ->{cancel}}, "cancel")
            )
          end
        )
      end

      def set_vote_poll_changed
        unless n_state(:vote_poll_changed)
          set_state vote_poll_changed: true
        end
      end

      def init_image_addition_to_vote_poll
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
        image.update_post_vote_poll_as_content(
          wilds: {post_vote_poll_id: n_state(:vote_poll).id}
        ).then do |u_img|
          if u_img.has_errors?
            u_img.errors.each do |er|
              n_state(:vote_poll).add_error(:m_content, er)
            end
          else
            n_state(:vote_poll).m_content = u_img
            n_state(:vote_poll).m_content_type = 'PostImage'
          end
          set_state(vote_poll: n_state(:vote_poll))
        end
      end

      def remove_image_from_vote_poll
        n_state(:vote_poll).m_content.remove_from_post_vote_poll(
          wilds: {post_vote_poll_id: n_state(:vote_poll).id}
        ).then do |image|
          if image.has_errors?
            image.errors.each do |er|
              n_state(:vote_poll).add_error(:m_content, er)
            end
          else
            n_state(:vote_poll).m_content = nil
            n_state(:vote_poll).m_content_type = nil
          end
          set_state vote_poll: n_state(:vote_poll)
        end
      end

      def init_option_addition
        modal_open(
          nil,
          t(Components::VotePollOptions::New, 
            {
              save_in_place: true, on_done: event(->(vote_option){insert_vote_option(vote_option)}),
              owner: self, vote_poll_option: VotePollOption.new
            }
          )
        )
      end

      def insert_vote_option(vote_option)
        modal_close
        n_state(:vote_poll).vote_poll_options.data << vote_option
        set_state vote_poll: n_state(:vote_poll)
      end

      def update_vote_poll
        collect_inputs
        n_state(:vote_poll).update.then do |vote_poll|
          if vote_poll.has_errors?            
            set_state({vote_poll: vote_poll})
          else
            set_state({vote_poll: vote_poll, vote_poll_changed: false})
          end
        end
      end

      def delete_option(vote_poll_option)
        n_state(:vote_poll).vote_poll_options.data.delete(vote_poll_option)
        set_state vote_poll: n_state(:vote_poll)
      end
    
    end
  end
end