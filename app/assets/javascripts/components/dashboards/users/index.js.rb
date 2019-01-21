module Components
  module Dashboards
    module Users
      class Index < RW

        expose

        SIGNUP_PROMOTION_MESSAGE = "Pssst, dude, wanna become registered? Name will be enough."


        def get_initial_state
          {
            on_main: false
          }
        end


        def should_show_signup_box?
          if !CurrentUser.instance_has_role?('name_provided') || CurrentUser.instance_has_role?('no_e_or_p') 
            true
          else
            false
          end
        end


        def render
          t(:div, {className: 'dashboards-index'},
            

              t(:div, {className: "controlls"},

                t(:ul, {},
                  link_to(
                    t(:li, {}, "create post"), 
                    "/dashboard/#{CurrentUser.instance.id}/posts/new"
                  ),
                  link_to(
                    t(:li, {}, "my posts"), 
                    "/dashboard/#{CurrentUser.instance.id}/posts/index"
                  ),
                  link_to(
                    t(:li, {}, "my account"), 
                    "/dashboard/#{CurrentUser.instance.id}/edit_account"
                  ),
                  # link_to(
                  #   t(:li, {}, 
                  #     "notifications",
                  #     if CurrentUser.has_unread_notifications
                  #       t(:span, {className: 'unread_notifications-label'},
                  #         CurrentUser.unread_notifications_count
                  #       )
                  #     end
                  #   ), 
                  #   "/dashboard/#{CurrentUser.instance.id}/notifications"
                  # ),
                  link_to(
                    t(:li, {}, "subscriptions"), 
                    "/dashboard/#{CurrentUser.instance.id}/subscriptions"
                  )
                )

              ),

              t(:div, {className: "content"},
                if state.on_main
                  t(:div, {className: 'row'},

                    t(:div, {className: 'col-lg-6'},
                      t(Components::Users::Show::GeneralInfo, 
                        {
                          user_id: CurrentUser.instance.id,
                          dashboard_mode: true
                        }
                      )
                    ),
                    t(:div, {className: 'col-lg-6'},
                      t(Components::DayKarmaStats::Index, {}),
                      if should_show_signup_box?
                        t(Components::Users::Create, {message: SIGNUP_PROMOTION_MESSAGE}) 
                      end,
                      t(Components::UserNotifications::Index, {notification: CurrentUser.instance.notifications})
                    )
                  )
                end,
                children
              )

            
          )
        end



        def component_did_mount
          check_if_on_main
          CurrentUser.instance.notifications = ModelCollection.new
          CurrentUser.ping_current_user.then do
            force_update
          end
        end


        def component_did_update(np, ns)
          check_if_on_main
        end



        def check_if_on_main
          if props.location.pathname == "/dashboard/#{CurrentUser.instance.id}"
            set_state on_main: true unless state.on_main
          else
            set_state on_main: false if state.on_main
          end
        end

        def user_logged_in(user_instance)
          set_state(user_credentials_details)
        end

      end
    end
  end
end
