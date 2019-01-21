module Components
  module Users
    class CurrentUserStatus < RW
      expose

      def self.instance
        @@instance
      end

      def init
        CurrentUser.subscribe(:user_logged_in, self)
        CurrentUser.subscribe(:user_logged_out, self)
        CurrentUser.subscribe(:karma_changed, self)
      end

      def component_will_unmount
        CurrentUser.unsubscribe(:user_logged_in, self)
        CurrentUser.unsubscribe(:user_logged_out, self)
        CurrentUser.unsubscribe(:karma_changed, self)
      end

      def get_initial_state
        logged_in = CurrentUser.logged_in
        {
          logged_in: logged_in,
          transition_blink: '',
          amount: false
        }
      end

      def render
        t(:div, {className: "current-user-status-bar"},
          if state.logged_in
            [
            t(:p, {},
              CurrentUser.instance.user_credential.name || 'guest'
            ),
            t(:p, {className: "user-karma #{n_state(:transition_blink)}"},
              t(:p, {}, CurrentUser.instance.user_karma.try(:count)),
              if n_state(:transition_blink) != ''
                if n_state(:amount)
                  should_plus = n_state(:amount) > 0 ? '+' : nil
                  t(:p, {}, "#{should_plus}#{n_state(:amount)}")
                end
              end
            )
            ]
          else
            t(:p, {},
              'not logged in'
            )
          end
        )
      end

      def user_logged_in
        set_state logged_in: true
      end

      def user_logged_out
        set_state logged_in: false
      end

      def karma_changed(amount)
        set_state(
          transition_blink: 'transitionBlink', 
          amount: amount
        )
        `
          setTimeout(
            function(){ 
              #{set_state(transition_blink: '')}; 
            }, 
            300
          );
        `
      end

    end
  end
end
