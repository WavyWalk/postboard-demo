module Components
  module Users
    class LoginOrContinueAsGuest < RW

      expose

      def render
        t(:div, {className: 'login-or-continue-as-guest'},
          t(:div, {className: 'row'},
            t(Components::Sessions::Create, {})
          ),
          t(:div, {className: 'row'},
            "or"
          ),
          t(:div, {className: 'row'},
            t(:a, {href: '/'},
              t(:button, {className: 'btn btn-primary'},
                "continue as guest"
              )
            )
          )
        )
      end

    end
  end
end