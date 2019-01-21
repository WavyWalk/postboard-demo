module Components
  module Users
    module Show
      class GeneralInfo < RW
        expose

        def component_did_mount
          if props.user_id
            user_id = props.user_id
          else
            user_id = props.params.user_id
          end

          User.general_info(wilds: {id: user_id}, component: self).then do |result|
            begin
            set_state result
            rescue Exception => e
              p e
            end
          end

        end

        def render
          p n_state(:total_posts)
          t(:div, {className: 'users-show-generalInfo'},
            progress_bar,
            if state.user
              [
              t(:div, {className: 'user'},
                t(Components::Users::Partials::AuthorLabel, 
                  {
                    user: n_state(:user),
                    show_only_name: (true if CurrentUser.instance.id == state.user.id),
                    promote_registration: promote_registration
                  }
                ),
                if n_state(:total_posts) && n_state(:total_posts) > 0
                  t(:p, {}, "total posts: #{state.total_posts}")
                else
                  no_post_message
                end
              ),
              if n_state(:top_post)
                [
                  t(:div, {className: 'topPost'},
                    t(:p, {}, 'best post so far:'),
                  ),
                  t(Components::Posts::ShowInline, {post: state.top_post, i: 'top_post', owner: self})
                ]
              end,
              if n_state(:latest_user_posts) && n_state(:latest_user_posts).data.length > 0
                [
                  t(:div, {className: 'latestPosts'},
                    t(:p, {}, 'latest posts:'),
                  ),
                  state.latest_user_posts.data.each_with_index.map do |post, i|
                    t(Components::Posts::ShowInline, 
                      {
                        post: post, 
                        i: i, 
                        owner: self
                      }
                    )
                  end
                ]
              end,
              t(:div, {className: 'topComment'},
                if state.top_comment
                  t(:div, {}, state.top_comment.content)
                end
              ),
              t(:div, {className: 'latestComments'},
                if state.latest_discussion_messages
                  state.latest_discussion_messages.map do |discussion_message|
                    t(:div, {className: 'commentContent'},
                      discussion_message.content
                    )
                  end
                end
              )
              ]
            end
          )
        end

        def promote_registration
          if n_prop(:dashboard_mode)
            (n_state(:user).name ? false : true)
          end
        end

        def no_post_message
          if n_prop(:dashboard_mode)
            t(:p, {}, 
              "you have not yet created any posts, ",
              link_to(
                "go ahead",
                "/dashboard/#{CurrentUser.instance.id}/posts/new"
              ),
              " it's easy and fun!"
            )
          else
            t(:p, {},
              'this user has not created any post yet'
            )
          end          
        end

        #blank method, is called from Posts::ShowInline child via calling at owner
        #is used in compbination with ShowProxy, to show current without fetching
        def set_current_post_for_show(post)

        end

      end
    end
  end
end
