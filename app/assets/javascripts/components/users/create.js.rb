module Components
  module Users
    class Create < RW
      expose

      include Plugins::Formable

      def get_initial_state
        step = 0
        if !CurrentUser.instance_has_role?('name_provided')
          step = 0
        elsif CurrentUser.instance_has_role?('no_e_or_p')
          step = 1
        end
        {
          user: CurrentUser.instance,
          step: step
        }
      end

      def render

        t(:div, {className: 'users-create'},
          progress_bar,

          if state.step == 0 || props.no_steps
            [
              if props.message
                t(:div, {className: 'message'},
                  t(:p, {}, props.message)
                )
              end,
              input(Components::Forms::Input, state.user.user_credential, :name, {show_name: 'nickname', required_field: true}),
              unless props.no_steps
                t(:div, {className: "btn-controll"},
                  t(:button, {onClick: ->{submit}, className: 'btn btn-default' }, 'submit')
                )
              end,
              t(:h3, {className: 'or'}, "or"),
              t(:div, {className: 'oath-provider-list'},
                t(:h3, {}, 'create account via:'),
                t(:button, {className: 'btn btn-primary', onClick: ->{open_popup_for_oauth('http://localhost:3000/auth/developer')}}, "DEVELOPER")
              )
            ]
          end,

          if state.step == 1 || props.no_steps

            [
            if state.transition_from_0 
              t(:p, {className: 'afterSignupMessage'}, "congratulations you've been registered!")
            end,
            t(Components::Users::Avatars::Edit, 
              {
                user: n_state(:user),
                user_id: CurrentUser.instance.id
              }
            ),
            t(:p, {className: 'message'}, 'if you want to login later in future, leave either password or email, or both, but this is not required'),
            t(:div, {className: 'emailAndPwdContainer'},
              t(:div, {className: 'row'},
                t(:div, {className: 'col-lg-6 emailBlock'},
                  input(Components::Forms::Input, state.user.user_credential, :email, {show_name: 'email', type: 'email', optional_field: true})
                ),
                t(:div, {className: 'col-lg-6 pwdBlock'},
                  input(Components::Forms::Input, state.user.user_credential, :password, {type: 'password', show_name: 'password', optional_field: true}),
                  input(Components::Forms::Input, state.user.user_credential, :password_confirmation, {type: 'password', show_name: 'confirm password'})
                )
              )
            ),
            t(:div, {className: "btn-controll"},
              t(:button, {onClick: ->{submit}, className: 'btn btn-primary'}, 'submit')
            )
            #t(:button, {onClick: ->{hide}, className: 'btn btn-default' }, "nah, I'm cool")
            ]
          end
        )
      end

      def hide
        set_state step: false
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

        unless state.user.has_errors?
          state.user.create(component: self).then do |user|

            if user.has_errors?
              set_state user: user
            else

              #CurrentUser.set_user_and_login_status(user, true)

              if props.on_signup
                emit(:on_signup, user)
              else
                #$HISTORY.pushState(nil, '/')
              end

              if state.step == 0
                set_state step: 1, transition_from_0: true
              else
                #case submits empty fields (step 1 considered to assign pass or email, so if not should remain on that step)
                no_e_or_p = false
                user.user_roles.each do |user_role|
                  if user_role.name == 'no_e_or_p'
                    no_e_or_p = true
                    break
                  end
                end
                unless no_e_or_p
                  set_state step: false
                else
                  force_update
                end
              end

            end
          end

        else
          set_state user: state.user
        end

      end

    end
  end
end
