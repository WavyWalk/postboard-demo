module Components
  module Sessions
    class Create < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          user: User.new(user_credential: UserCredential.new)
        }
      end

      def render
        t(:div, {className: 'users-create'},

          display_general_errors_for(state.user.user_credential),
          t(:div, {className: 'oauth-block'},
            t(:h3, {}, 'login via:'),
            t(:div, {className: 'oath-provider-list'},
              t(:button, {className: 'btn btn-default', onClick: ->{open_popup_for_oauth('http://localhost:3000/auth/developer')}}, "DEVELOPER")
            )
          ),
          t(:div, {className: 'login-via-email'},
            [
              t(:h3, {}, 'login via email that will be sent to you'),
              input(Components::Forms::Input, state.user.user_credential, :email, {show_name: 'your email'}),
              t(:div, {className: 'controll-buttons'},
                t(:button, {className: 'btn btn-default', onClick: ->{submit_via_link}}, 'send me login link')
              )
            ]
          ),
          t(:div, {className: 'login-via-pwd'},
            t(:h3, {}, 'login with email and password'),
            input(Components::Forms::Input, state.user.user_credential, :email, {type: 'email', show_name: 'your username or email'}),
            input(Components::Forms::Input, state.user.user_credential, :password, {type: 'password', show_name: 'password'}),
            t(:div, {className: 'controll-buttons'},
              t(:button, {className: 'btn btn-default', onClick: ->{submit_via_pwd}}, 'login')
            )
          )
        )
      end

      def submit_via_link
        collect_inputs(form_model: :user)

        if state.user.has_errors?
          set_state user: state.user
        else
          state.user.send_login_link.then do |user|
            if user.has_errors?
              set_state user: user
            else
              alert 'logged in'
            end
          end
        end
      end

      #opens child window which redirects on success
      #that redirected page controller renders view with js that will call proc set in OauthHelper
      def open_popup_for_oauth(path)
        OauthHelper.set_proc_on_auth_popup_close do
          CurrentUser.instance.ping_current_user.then do |user|
            CurrentUser.set_user_and_login_status(CurrentUser.instance, true)
          end
        end
        OauthHelper.open_child_window(path)
      end

      def submit_via_pwd
        collect_inputs(form_model: :user)
        if state.user.has_errors?
          set_state user: state.user
        else
          state.user.login_via_pwd.then do |user|
            if user.has_errors?
              set_state user: user
            else
              CurrentUser.set_user_and_login_status(user, true)
              alert 'logged in'
            end
          end
        end
      end

    end
  end
end
