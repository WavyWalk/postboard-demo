module Components
  module Menues
    class Top < RW

      expose
      #include Plugins::UpdateOnSetStateOnly

      def init
        CurrentUser.subscribe(:user_logged_in, self)
      end

      def user_logged_in
        force_update
      end

      def get_initial_state
        {
          m_open: false
        }
      end

      def render

        if $IS_MOBILE
          mobile_render
        else
          regular_render
        end

      end


      def mobile_render
        t(:div, {className: 'm-menu'},

          t(:button, {type: "button",
                     onClick: ->(){m_toggle_menu}},
            "menu"
          ),

          t(:div, {className: "m-menu-hidden-part #{state.m_open}"},
            t(:button, {className: "g-close-btn btn-xs", onClick: ->{m_toggle_menu}}, 'X'),
            t(:ul, {},
              link_to( t(:li, {},'home'), '/'),
              link_to( t(:li, {},'test signup'), '/signup'),
              link_to( t(:li, {},'test login'), '/login'),
              link_to( t(:li, {}, 'dashboard'), "/dashboard/#{CurrentUser.instance.id}"),
              link_to( t(:li, {}, 'staff_userSubmitted_Unpublished_Posts_Index'), '/staff/user_submitted/posts/index')
            )
          )

        )
      end

      def regular_render
        t(:div, {className: 'menu'},
          t(:ul, {},
            link_to( t(:li, {},'home'), '/'),
            if CurrentUser.instance == nil || CurrentUser.instance.has_role?('no_name')
              [
                link_to( t(:li, {},'signup'), '/signup'),
                link_to(t(:li, {},'login'), '/login')
              ]
            end,
            link_to( t(:li, {}, 'dashboard'), "/dashboard/#{CurrentUser.instance.id}"),
            if CurrentUser.instance.id && !CurrentUser.instance.has_role?('guest')
              t(:li, {onClick: ->{logout}}, 'logout') 
            end,
            if CurrentUser.instance && CurrentUser.instance.has_role?('staff')
              link_to( t(:li, {}, 'staff_userSubmitted_Unpublished_Posts_Index'), '/staff/user_submitted/posts/index')
            end,
            t(:li, {},
              link_to('test', '/test')
            )
          ),
          t(Components::Users::CurrentUserStatus, {})
        )
      end


      def m_toggle_menu
        set_state m_open: !state.m_open
      end

      def toggle_collapse
        set_state collapsed: !state.collapsed
      end

      def clear_opened(d_d)
        refs.each do |k,v|
          if k.include? "d_d"
            v.rb.set_state open: false unless (v.rb == d_d)
          end
        end
      end

      def component_will_unmount
        CurrentUser.unsubscribe(:user_logged_in, self)
      end

      def logout
        CurrentUser.logout.then do
          $HISTORY.pushState(nil, "/login_or_continue_as_guest")
        end
      end

    end
  end
end
