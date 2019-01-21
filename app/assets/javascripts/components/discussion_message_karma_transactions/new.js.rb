module Components
  module DiscussionMessageKarmaTransactions
    class New < RW
      expose

      def validate_props
        if !props.discussion_message_karma_transaction_for_cu.is_a?(DiscussionMessageKarmaTransaction)
          puts "#{self} of #{self.class.name} required prop :discussion_message_karma_id of Integer was not passed,
                instead got #{props.discussion_message_karma_id} of #{props.discussion_message_karma_id.class.name}"
        end
      end

      def get_initial_state

      end

      def render
        t(:div, {className: 'discussion-message-karma-transactions-new'},
          t(:span, { onClick: ->{ like }, className: liked? },
            t(:i, {className: 'icon-thumbs-up-1'})
          ),
          t(:span, { onClick: ->{ dislike }, className: disliked? },
            t(:i, {className: 'icon-thumbs-down-1'})
          )
        )
      end

      def liked?
        dmkt = n_prop(:discussion_message_karma_transaction_for_cu)
        if dmkt.try(:amount) && dmkt.amount > 0
          'liked'
        end
      end

      def disliked?
        dmkt = n_prop(:discussion_message_karma_transaction_for_cu)
        if dmkt.try(:amount) && dmkt.amount < 0
          'disliked'
        end
      end

      def like
        dmkt = n_prop(:discussion_message_karma_transaction_for_cu)
        dmkt.previous_amount = dmkt.amount || 0
        dmkt.amount = 1
        create
      end

      def dislike
        dmkt = n_prop(:discussion_message_karma_transaction_for_cu)
        dmkt.previous_amount = dmkt.amount || 0
        dmkt.amount = -1
        create
      end

      def create
        n_prop(:discussion_message_karma_transaction_for_cu).create.then do |discussion_message_karma_transaction|
          begin
          if discussion_message_karma_transaction.has_errors?
            if discussion_message_karma_transaction.errors[:general]
              alert discussion_message_karma_transaction.errors[:general]
              discussion_message_karma_transaction.amount = discussion_message_karma_transaction.previous_amount
            else
              #set_state discussion_message_karma_transaction: discussion_message_karma_transaction

            end
          else

            CurrentUser.update_karma(discussion_message_karma_transaction.attributes[:user_change_amount])

            n_prop(:discussion_message_karma_transaction_for_cu).attributes = discussion_message_karma_transaction.attributes
            emit(:on_discussion_message_karma_transaction_created, discussion_message_karma_transaction)
            force_update

          end
          rescue Exception => e
           p e
          end
        end
      end


    end
  end
end
