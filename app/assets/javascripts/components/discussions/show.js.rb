module Components
  module Discussions
    class Show < RW
      expose

      #PROPS
      #Optional
      #discussion : Discussion
      #
      # def validate_props
      #   if props.discussion || !props.discussion.is_a?(Discussion)
      #     puts "#{self} of #{self.class.name} require props.discussion was not passed
      #           or was not of Discussion type; got #{props.discussion} of #{props.discussion.class} instead"
      #   end
      # end

      def get_initial_state
        {
          discussion: false,
          current_reply: false
        }
      end


      def component_did_mount

        id_to_fecth = props.post_id

        Discussion.show(wilds: {discussable_id: id_to_fecth}, component: self, namespace: 'posts', yield_response: true).then do |response|
          begin
          jsoned_response = response.json

          discussion = Discussion.parse(jsoned_response[:discussion])

          message_authors = User.parse(jsoned_response[:message_authors])

          cached_authors = {}

          message_authors.each do |author|
            cached_authors[author.id] = author
          end

          sorted_messages = sort_by_parent_child(discussion.discussion_messages)

          set_state discussion: discussion, message_authors: cached_authors, sorted_messages: sorted_messages

          fetch_discussion_messages_karma_transactions_for_cu(discussion.discussion_messages)

          scroll_into_view_if_necessary
          rescue Exception => e
            p e
          end 
        end

      end

      def scroll_into_view_if_necessary
        if n_prop(:should_scroll_to_comments)
          `
            var discussionsBlock = $('.discussions-block')[0];
            if (typeof(discussionsBlock != 'undefined')) {
              discussionsBlock.scrollIntoView();
            }
          `
        end
      end

      def fetch_discussion_messages_karma_transactions_for_cu(discussion_messages)

        if discussion_messages
          map = {}
          discussion_messages_ids = discussion_messages.data.map do |dm|
            map[dm.discussion_message_karma.id] = dm.discussion_message_karma
            dm.discussion_message_karma.id
          end
          
          DiscussionMessageKarmaTransaction.index_for_cu(payload: {ids: discussion_messages_ids}).then do |dm_trs|
            dm_trs.data.each do |tr|
              map[tr.discussion_message_karma_id].discussion_message_karma_transaction_for_cu_or_new.attributes = tr.attributes
            end
            force_update
          end


        end
      rescue Exception => e
        p e
      end


      def component_will_receive_props(np)
        if np.post_id != props.post_id
          props.post_id = np.post_id
          set_state get_initial_state
          component_did_mount
        end
      end

      def render
        t(:div, {className: 'discussions-show'},
          progress_bar,
          if state.discussion
            [
              if !state.current_reply
                t(Components::DiscussionMessages::New, 
                  {
                    discussion_id: state.discussion.id,
                    holding_message: state.sorted_messages,
                    on_message_submitted: event(->(msg, holding_message){on_message_submitted(msg, holding_message)})
                  }
                )
              end,
              render_children_for_message(state.sorted_messages, 0)
            ]
          end
        )
      end

      def render_children_for_message(message_collection, child_level)

        message_collection.children_messages.map do |message|
          t(:div, { className: 'discussion-message', style: {"margin-left" => "#{child_level}rem"}.to_n },
            #"reply to #{message.discussion_message_id} child_level: #{child_level}",
            t(:div, {className: 'head'},
              t(:div, {},
                if user = n_state(:message_authors)[message.user_id]
                  t(Components::Users::Partials::AuthorLabel, 
                    {
                      user: user,
                      show_only_name: true
                    }
                  )
                else
                  t(Components::Users::Partials::AuthorLabel, 
                    {
                      user: CurrentUser.instance,
                    }
                  )
                end
              ),
              t(:div, {},
                if message.try(:discussion_message_karma)
                  t(Components::DiscussionMessageKarmas::Show, 
                    {
                      discussion_message_karma: message.discussion_message_karma,
                      on_karma_changed: event(->(dmkt){on_karma_changed(dmkt, n_state(:message_authors)[message.user_id].try(:id))})
                    }
                  )
                end
              )
            ),
            t(:div, {className: 'message-body'},
              t(:div, 
                {
                  className: 'text', 
                  dangerouslySetInnerHTML: {__html: message.content}.to_n
                }
              ),
              t(:div, {},
                message_controlls(message)
              )
            ),
            if state.current_reply == message.id
              t(Components::DiscussionMessages::New, 
                {
                  discussion_id: state.discussion.id,
                  reply_to: message.id,
                  on_cancel_reply: event(->{cancel_reply}),
                  holding_message: message,
                  on_message_submitted: event(->(msg, holding_message){on_message_submitted(msg, holding_message)})
                }
              )
            end,
            #"#{state.message_authors[message.user_id]}: #{message.content}; id: #{message.id} reply to: #{message.discussion_message_id}",

            if !message.children_messages.empty?
              render_children_for_message(message, 2)
            end
          )
        end

      end


      def on_karma_changed(dmkt, user_id) 
        amount_to_increment_on = dmkt.amount_change_factor * Services::KarmaManager::USERS_COMMENT_UP_OR_DOWN_VOTED
        n_state(:message_authors).each do |key, user|
          if user.id == user_id
            user.user_karma.count += amount_to_increment_on
          end
        end
        force_update
      end

      def message_controlls(message)
        t(:div, {className: 'message-controlls'},
          t(:span, {onClick: ->{ set_reply_to(message.id) }},
            t(:i, {className: 'icon-comment-empty'}),
            'reply'
          )
        )
      end

      def cancel_reply
        set_state current_reply: false
      end

      def set_reply_to(message_id)
        set_state current_reply: message_id
      end

      def sort_by_parent_child(array)

        target_hash = Hash.new { |h,k| h[k] = { id: nil, message: DiscussionMessage.new } }

        array.each do |message|
            id, parent_id = message.id, (!!(x  = message.discussion_message_id) ? x : 0)
            target_hash[id][:id] = message.id
            target_hash[id][:message] = message
            target_hash[parent_id][:message].children_messages << target_hash[id][:message]
        end

        target_hash[0][:message]

      end

      def on_message_submitted(message, holding_message)

        holding_message.children_messages << message
        state.discussion.discussion_messages << message

        set_state current_reply: false, sorted_messages: state.sorted_messages

      rescue Exception => e
        p e
      end

    end
  end
end
