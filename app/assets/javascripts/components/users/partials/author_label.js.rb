module Components
  module Users
    module Partials
      class AuthorLabel < RW
        expose

        def validate_props
          p "no user passed to #{self.class.name}" unless n_prop(:user)
          #subscription_changed : Event
          #show_only_name : Boolean
        end

        def render
          user = n_prop(:user)
          t(:div, {className: 'Users-Partials-AuthorLabel'},
            t(:div, {className: 'avatar'},
              t(:i, {className: 'icon-user-o'})
            ),
            t(:div, {className: 'name-karma'},
              if n_prop(:promote_registration)
                t(:div, {className: 'name'},
                  link_to(
                    'create nickname',
                    '/dashboard/#{CurrentUser.instance.id}/edit_account'
                  )
                )
              else
                t(:div, {className: 'name'},
                  link_to(user.name, "users/#{user.id}")
                )
              end,
              t(:div, {className: 'karma'},
                user.user_karma.try(:count)
              )
            ),
            unless n_prop(:show_only_name)
              t(Components::UserSubscriptions::CreateOrShow,
                user_to_subscribe_to: user,
                subscription_changed: n_prop(:subscription_changed)
              )
            end
          )
        end

      end
    end
  end
end