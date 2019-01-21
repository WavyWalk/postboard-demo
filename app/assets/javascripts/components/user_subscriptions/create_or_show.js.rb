module Components
  module UserSubscriptions
    class CreateOrShow < RW
      expose

      def validate_props
        #props.user_to_subscribe_to #required
      end


      def render
        t(:div, {className: 'userSubscriptions-createOrShow'},
          unless n_prop(:user_to_subscribe_to).usub_with_current_user.try(:id)
            t(:button, {className: 'subscribe-btn zoom btn btn-primary btn-sm', onClick: ->{create_subscription}},
              #t(:button, { className: 'btn btn-default', onClick: ->{create_subscription} },
                t(:span, {className: 'text'}, 'subscribe'),
                if uds = n_prop(:user_to_subscribe_to).user_denormalized_stat
                  t(:span, {className: 'subscriberCount'}, uds.subscribers_count)
                end
              #)
            )
          else
            t(:button, {className: 'subscribe-btn zoom btn btn-primary btn-sm btn-danger', onClick: ->{destroy_subscription}},
              #t(:button, {className: 'btn btn-default',onClick: ->{destroy_subscription} },
                'Unsubscribe'
              #)
            )
          end
        )
      end

      def create_subscription
        us = UserSubscription.new
        us.to_user_id = props.user_to_subscribe_to.id

        us.create.then do |user_subscription|
          begin
          n_prop(:user_to_subscribe_to).usub_with_current_user = us
          CurrentUser.update_karma(KarmaManager::WHEN_SUBSCRIBED_TO_USER)
          emit :subscription_changed, props.user_to_subscribe_to, user_subscription, :subscribed
          rescue Exception => e
            p e
          end
        end
        force_update
      end

      def destroy_subscription
        props.user_to_subscribe_to.usub_with_current_user.destroy.then do |user_subscription|
          CurrentUser.update_karma(KarmaManager::WHEN_UNSUBSCRIBED_FROM_USER)
          emit :subscription_changed, props.user_to_subscribe_to, user_subscription, :unsubscribed
          props.user_to_subscribe_to.usub_with_current_user.id = nil
          force_update
        end
      end

    end
  end
end
