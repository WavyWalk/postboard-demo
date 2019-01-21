module Components
  module App
    class Router < RW

      expose

      class << self
        attr_accessor :phantom_instance
      #DISPLAY SIZE RELATED
        def set_app_instance(value)
          @app_instance = value
        end

        def get_app_instance
          @app_instance
        end

        def set_display_size

          screen_width = Element.find(`window`).width()

          screen_type = 'g-lg'

          if screen_width <= 768
            screen_type = 'g-sm'
          end

          $DISPLAY_SIZE = screen_type

          if $DISPLAY_SIZE == 'g-sm'
            $IS_MOBILE = true
          else
            $IS_MOBILE = false
          end

          $CLIENT_WIDTH = `window.innerWidth||document.documentElement.clientWidth||document.body.clientWidth`

          $CLIENT_HEIGHT = `window.innerHeight||document.documentElement.clientHeight||document.body.clientHeight`

        end

        def set_resize_listener
          Element.find(`window`).on 'resize', self.on_window_resize
        end

        def on_window_resize
          -> {
            self.set_display_size
          }
        end
      #END DISPLAY SIZE RELATED

      end

      def component_did_mount
        self.class.set_app_instance(self)
      end

      def init
        #setting props passed from server in script tag for further usage in components
        Services::PropsFromServer.set_props
        #required only for prerendering
        #to remove delete also #services/phantom_yielder #plugins/phantom_yielder
        #includable plugins/phantom_yielder accesse phantom yielder ass App::Components::Router.phantom_instace
        self.class.phantom_instance = Services::PhantomYielder.new
        #set global history accessor; it could be implemented as singleton.
        $HISTORY = Native(`ReactRouter.browserHistory`)
        #handle if current user was passed from server on bootstrapping
        check_and_set_current_user_if_logged_in
        #set global viewport size accessor; it could be implemented as singleton
        self.class.set_display_size
        #sets resize listener which will call set_display_size on event
        self.class.set_resize_listener
        #Start polling for user notifications
        UserNotificationsManager.instance

      end

      #reads props from server and if current user is passed from server sets CurrentUser
      #as logged in and provides passed instance for it
      def check_and_set_current_user_if_logged_in

        if x = Services::PropsFromServer.props[:current_user]

          user = User.parse(x)

          CurrentUser.set_user_and_login_status(user, true)

        end

      end

      def render
        t(`ReactRouter.Router`, {history: `ReactRouter.browserHistory`},

          t(`ReactRouter.Route`, {path: "/login_or_continue_as_guest", component: Components::Users::LoginOrContinueAsGuest.create_class}),

          t(`ReactRouter.Route`, {path: "/", component: Components::App::Main.create_class},

            t(`ReactRouter.Route`, {path: "error404", component: Components::App::NotFound.create_class}),
            #that m is used at /:post_id route, to be used as same component; posts/index decides itself what to render
            #depending on props.location
            t(`ReactRouter.IndexRoute`, {component: m = Components::App::IndexRoute.create_class}),

            t(`ReactRouter.Route`, {path: 'test', component: Test.create_class}),

            t(`ReactRouter.Route`, {path: 'signup', component: Components::Users::Create.create_class}),

            t(`ReactRouter.Route`, {path: 'login', component: Components::Sessions::Create.create_class}),

            t(`ReactRouter.Route`, {path: 'posts', component: Components::Posts::Main.create_class},

              t(`ReactRouter.Route`, {path: 'index', component: Components::Posts::Index.create_class},

                t(`ReactRouter.Route`, {path: ':post_id', component: Components::Posts::ShowProxy.create_class})

              ),

              t(`ReactRouter.Route`, {path: 'new', component: Components::Posts::New.create_class}),

              t(`ReactRouter.Route`, {path: ':post_id', component: Components::Posts::Show.create_class})

            ),

            #for testing
            t(`ReactRouter.Route`, {path: 'new_gif', component: Components::PostGifs::New.create_class}),
            #for testing
            t(`ReactRouter.Route`, {path: 'show_gif/:id', component: Components::PostGifs::Show.create_class}),


            t(`ReactRouter.Route`, {path: 'upload_image', component: Components::PostImages::UploadAndPreview.create_class}),

            t(`ReactRouter.Route`, {path: 'test', component: Components::App::Test.create_class}),

            t(`ReactRouter.Route`, {path: 'staff', component: Components::Staff::Main.create_class},

              t(`ReactRouter.Route`, {path: 'user_submitted/posts', component: Components::Staff::UserSubmitted::Posts::Main.create_class},

                t(`ReactRouter.Route`, {path: 'index', component: Components::Staff::UserSubmitted::Posts::Index.create_class})

              ),

              t(`ReactRouter.Route`, {path: 'posts', component: Components::Staff::Posts::Main.create_class},

                t(`ReactRouter.Route`, {path: 'new', component: Components::Staff::Posts::New.create_class})

              )

            ),



            t(`ReactRouter.Route`, {path: "dashboard/:user_id", component: Components::Dashboards::Users::Index.create_class},

              t(`ReactRouter.Route`, {path: "posts/new", component: Components::Posts::New.create_class}),

              t(`ReactRouter.Route`, {path: "edit_account", component: Components::Users::Edit.create_class}),

              t(`ReactRouter.Route`, {path: "posts/index", component: Components::Users::Posts::Index.create_class},
                t(`ReactRouter.Route`, {path: ":post_id", component: Components::Posts::ShowProxy.create_class})
              ),

              t(`ReactRouter.Route`, {path: "notifications", component: Components::UserNotifications::Index.create_class}),

              t(`ReactRouter.Route`, {path: "subscriptions", component: Components::Users::UserSubscriptions::Index.create_class})

            ),


            t(`ReactRouter.Route`, {path: "users/:user_id", component: Components::Users::Show::Main.create_class},

              t(`ReactRouter.Route`, {path: "general_info", component: Components::Users::Show::GeneralInfo.create_class}),
              t(`ReactRouter.Route`, {path: "posts", component: Components::Users::Posts::Index.create_class},
                t(`ReactRouter.Route`, {path: ":post_id", component: Components::Posts::ShowProxy.create_class})
              )


            ),

            t(`ReactRouter.Route`, {path: ":post_id", component: m})


          ),


          t(`ReactRouter.Route`, {path: "*", component: Components::App::NotFound.create_class})

        )
      end

    end



  end
end
