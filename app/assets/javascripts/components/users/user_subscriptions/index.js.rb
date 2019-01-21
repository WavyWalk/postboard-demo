module Components
  module Users
    module UserSubscriptions
      class Index < RW
        expose

        def get_initial_state
          {
            users: ModelCollection.new,
            no_subs: false
          }
        end

        def component_did_mount
          #RERTURN USER COLLECTION!!!!!!!
          UserSubscription.index_for_user(wilds: {id: CurrentUser.instance.id}).then do |users|
            no_subs = users.data.length < 1 ? true : false
            set_state users: users, no_subs: no_subs
          end
        end

        def render
          t(:div, {className: "UserSubscriptions-Index"},
            if n_state(:no_subs)
              "you have no subscriptions yet"
            end,
            state.users.map do |user|
              t(Components::Users::Partials::AuthorLabel, 
                {
                  user: user#,
                  #subscription_changed: (event(->(user, user_subscription, status){post.make_dirty ; subscription_changed(user, user_subscription, status)}))
                }
              )      
            end
          )
        end


        # def subscription_changed(user, subscription, status)
        #   case status
        #   when :subscribed
        #     nil
        #   when :unsubscribed
        #     subscription.id = nil
        #   end
        #   set_state user_subscriptions: state.user_subscriptions
        # end



      end
    end
  end
end
