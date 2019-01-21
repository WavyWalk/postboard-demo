module Components
  module DiscussionMessages
    class New < RW
      expose

      include Plugins::Formable
      #PROPS
      #REQUIRED
      #discussion_id : Integer | numeric String
      def validate_props

        if !props.discussion_id || props.discussion_id.to_s == 0

          puts "#{self} of #{self.class.name} props.discussion_id should be numeric String
                or Integer; instead got #{props.discussion_id} of #{props.discussion_id.class.name}"

        end

      end

      def get_initial_state
        new_message = DiscussionMessage.new
        new_message.discussion_id = props.discussion_id
        if props.reply_to
          new_message.discussion_message_id = props.reply_to
        end 
        {
          discussion_message: new_message
        }
      end

      def render
        t(:div, {},
          modal,
          input(
            Components::Forms::WysiTextarea, 
            state.discussion_message, 
            :content, 
            {
              show_name: "leave comment", 
              reset_value: true,
              parse_rules: DiscussionMessage.wysi_textarea_parse_rules,
              allow_media_insert: true
            }
          ),
          t(:button, { onClick: ->{submit} }, 'submit'),
          if props.reply_to
            t(:button, { onClick: ->{ emit(:on_cancel_reply) } }, 'cancel')
          end
        )
      end

      def submit
        collect_inputs(form_model: :discussion_message)

        state.discussion_message.create(namespace: :posts).then do |discussion_message|
          unless discussion_message.has_errors?
            set_state get_initial_state
            clear_inputs
            CurrentUser.update_karma(Services::KarmaManager::FOR_COMMENT_CREATION)
            emit(:on_message_submitted, discussion_message, props.holding_message)
          else
            if discussion_message.errors['general'] == 'no_name'
              modal_open(
                t(Components::Users::Create, {message: 'to leave comment you should at least leave your nickname', on_signup: event(->{after_signup_ok})})
              )
            else
              set_state discussion_message: discussion_message
            end
          end
        end
      end

      def after_signup_ok
        modal_close
        submit
      end

    end
  end
end
