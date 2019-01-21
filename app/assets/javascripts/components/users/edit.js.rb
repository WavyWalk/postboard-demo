module Components
  module Users
    class Edit < RW


      expose

      include Plugins::Formable

      def component_did_mount
        CurrentUser.ping_current_user(component: self).then do |user|
          begin
          set_initial_fields(user)
          set_state user: user
          rescue Exception => e
            p e
          end
        end
      end

      def get_initial_state
        {
          user: false
        }
      end

      def set_initial_fields(user)
        @has_name = user.user_credential.name.blank? ? false : true
        @has_email = user.user_credential.email.blank? ? false : true
        @has_password = user.attributes[:has_password] ? true : false
      end

      def render
        t(:div, {},
          progress_bar,
          if state.ok_message
            t(:p, {}, state.ok_message)
          end,
          if state.user
            t(:div, {className: 'users-create'},
              t(:div, {className: 'avatar-name-group'},
                #warning: avatar updates current user
                t(Components::Users::Avatars::Edit, 
                  {
                    user: n_state(:user),
                    user_id: CurrentUser.instance.id
                  }
                ),
                if !@has_name
                  input(Components::Forms::Input, state.user.user_credential, :name, {show_name: 'username', required_field: true})
                else
                  t(:p, {className: 'name'}, state.user.user_credential.name) 
                end
              ),
              t(:div, {className: 'emailAndPwdContainer'},
                t(:div, {className: 'row'},
                  t(:div, {className: 'col-lg-6 emailBlock'},
                    t(:p, {}, 'create account from PROVIDER'),
                    t(:button, {onClick: ->{open_popup_for_oauth('http://localhost:3000/auth/developer')}}, "DEVELOPER")
                  ),
                  t(:div, {className: 'col-lg-6 pwdBlock'},
                    if !@has_email
                      input(Components::Forms::Input, state.user.user_credential, :email, {show_name: 'email', type: 'email', optional_field: true})
                    else
                      t(:p, {}, state.user.user_credential.email)
                    end,
                    if !@has_password
                      t(:p, {}, 'set password')
                      [
                      input(Components::Forms::Input, state.user.user_credential, :password, {type: 'password', show_name: 'password', optional_field: true, namespace: 'pwdgroup'}),
                      input(Components::Forms::Input, state.user.user_credential, :password_confirmation, {type: 'password', show_name: 'confirm password', namespace: 'pwdgroup'})
                      ]
                    else
                      [
                      t(:p, {}, 'change password'),
                      input(Components::Forms::Input, state.user.user_credential, :old_password, {show_name: 'old password', namespace: 'pwdgroup'}),
                      input(Components::Forms::Input, state.user.user_credential, :password, {type: 'password', show_name: 'new password', namespace: 'pwdgroup'}),
                      input(Components::Forms::Input, state.user.user_credential, :password_confirmation, {type: 'password', show_name: 'confirm new password', namespace: 'pwdgroup'})
                      ]
                    end
                  )
                )
              ),
              t(:button, {onClick: ->{submit}, className: 'btn btn-default'}, 'submit'),
            )
          end
        )
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

      



      def submit

        collect_inputs(form_model: :user)
        if state.user.has_errors?
          set_state user: state.user
        else
          state.user.create(component: self).then do |user|

            if user.has_errors?
              set_state user: user
            else
              clear_inputs('pwdgroup')
              CurrentUser.set_user_and_login_status(user, true)

              set_state user: user, ok_message: 'account successfully udpated'

            end

          end
        end

      end


    end
  end
end
