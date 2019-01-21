module Components
  module DiscussionMessageKarmas
    class Show < RW
      expose

      def validate_props
        if !props.discussion_message_karma.is_a?(DiscussionMessageKarma)
          puts "#{self.class.name} #{self} requires prop discussion_message_karma of DiscussionMessageKarma,
                instead got #{props.discussion_message_karma} of #{props.discussion_message_karma.class.name} "
        end
      end

      def get_initial_state
        {
          discussion_message_karma: props.discussion_message_karma
        }
      end

      def render
        t(:div, {className: 'karmaBlock'},
          t(Components::DiscussionMessageKarmaTransactions::New, {
              #discussion_message_karma_id: state.discussion_message_karma.id,
              discussion_message_karma_transaction_for_cu: n_prop(:discussion_message_karma).discussion_message_karma_transaction_for_cu_or_new,
              discussion_message_karma: n_prop(:discussion_message_karma),
              on_discussion_message_karma_transaction_created: event(->(dmkt){on_discussion_message_karma_transaction_created(dmkt)})
              # on_discussion_message_karma_transaction_created: event(
              #   ->(amount){on_discussion_message_karma_transaction_created(amount)}
              # )
            }
          ),
          t(:span, {className: 'count'}, "#{state.discussion_message_karma.count}")
        )
      end

      def on_discussion_message_karma_transaction_created(dmkt)
        n_prop(:discussion_message_karma).count += dmkt.amount_change_factor
        emit(:on_karma_changed, dmkt)
        force_update
      end

    end
  end
end
