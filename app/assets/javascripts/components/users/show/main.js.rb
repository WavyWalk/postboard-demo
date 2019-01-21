module Components
  module Users
    module Show
      class Main < RW
        expose

        def on_main
          if n_prop(:location).JS[:pathname] == "users/#{n_prop(:params).JS[:user_id]}"
            true
          else
            false
          end
        end

        def render
          t(:div, {className: 'dashboards-index users-show'},

            t(:div, {className: "controlls"},

              t(:ul, {},

                link_to(
                  t(:li, {},
                    "users posts"
                  ),
                  "/users/#{n_prop(:params).JS[:user_id]}/posts"
                )
                # t(:li, {},
                #   link_to("users comments", "/users/#{n_prop(:params).JS[:user_id]}/comments")
                # )

              )

            ),

            t(:div, {className: "content"},
              if on_main
                t(Components::Users::Show::GeneralInfo, {params: props.params})
              end,
              children
            ),


          )
        end

      end
    end
  end
end
