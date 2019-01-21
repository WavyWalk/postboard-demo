module Components
  module Users
    module Posts
      class Index < RW

        expose

        include Plugins::InfiniteScrollable

        @current_post_for_show

        def self.instance
          @@instance
        end

        def self.current_post_for_show=(post)
          @current_post_for_show = post
        end

        def self.current_post_for_show
          @current_post_for_show
        end

        def self.clear_current_post_for_show
          @current_post_for_show = nil
        end

        def set_current_post_for_show(post)
          self.class.current_post_for_show = post
        end

        def init
          @@instance = self
          if @is_at_dashboard = (props.location.pathname == "/dashboard/#{props.params.user_id}/posts/index") ? true : false
            @post_link = "/dashboard/#{props.params.user_id}/posts/index"
          elsif @is_at_user_show = props.location.pathname == "/users/#{props.params.user_id}/posts" ? true : false
            @post_link = "/users/#{props.params.user_id}/posts"
          else
            if n_prop(:post_link)
              @post_link = n_prop(:post_link)
            else
              @post_link = nil
            end
          end
        end

        def index_to_show_map
          @index_to_show_map
        end

        def get_initial_state
          @index_to_show_map = {}
          @post_index_query_running = false
          {
            posts: ModelCollection.new,
            per_page: 10,
            no_posts: false
          }
        end

        def component_did_mount
          if n_prop(:posts)
            set_state posts: n_prop(:posts)
          elsif @is_at_dashboard || @is_at_user_show
            fetch_and_set_posts
          end
          # if props.location.pathname == "/dashboard/posts/index/#{props.params.id}"
          #   fetch_and_set_posts
          # end
        end

        def component_will_receive_props(np)
          if np.location != props.location && state.posts.data.empty?
            #if (props.location.pathname == "/dashboard/#{props.params.user_id}/posts/index") || (props.location.pathname == "/users/#{props.params.user_id}/posts")
              props.location = np.location
              init
              fetch_and_set_posts
            #end
          end
        end

        def fetch_and_set_posts(page = 1)
          return if @post_index_query_running
          @post_index_query_running = true
          if @is_at_user_show
            Post.index_for_user_show(wilds: {id: props.params.user_id}, extra_params: {page: page, per_page: state.per_page}).then do |posts|
              if page == 1
                #pagination will be in data, it's extracted later in handle, that's why < 2
                if posts.data.length < 2
                  set_state(no_posts: true)
                end
              end
              begin
              handle_in_then(posts)
              rescue Exception => e
                p e
              end
            end
          elsif @is_at_dashboard
            Post.index_for_user(wilds: {id: props.params.user_id}, extra_params: {page: page, per_page: state.per_page}).then do |posts|
              if page == 1
                #pagination will be in data, it's extracted later in handle, that's why < 2
                if posts.data.length < 2
                  set_state(no_posts: true)
                end
              end
              begin
              handle_in_then(posts)
              rescue Exception => e
                `console.log(#{e})`
              end
            end
          end
        end

        def handle_in_then(posts)
          if posts.data[0].attributes[:pagination]
            return
          end
          extract_pagination(posts)
          state.posts.data += posts.data
          set_state posts: n_state(:posts)
          listen_to_infinite_scroll_beacon
          @post_index_query_running = false
        end

        def render
          t(:div, {className: 'Users-Posts-Index'},
            children,
            if n_state(:no_posts)
              no_posts_message
            end,
            state.posts.data.map.with_index do |post, i|

              t(Components::Posts::ShowInline, 
                {
                  post_link_preceding_part: @post_link, 
                  post: post, 
                  owner: self, 
                  i: i, 
                  key: i}
              )
              # t(:div, {ref: "post#{i}"},
              #   t(:div, {className: 'post-head'},
              #     t(:h1, {className: 'post-title', onClick: ->{set_current_post_for_show(post)} }, link_to("#{post.title}", "#{@post_link}/#{post.id}")),
              #     t(:h1, {className: 'post-karma-count'}, "post karma: #{post.post_karma.try(:count)}"),
              #   ),
              #   if !post.attributes[:opened]
              #     t(:div, {},
              #       t(:div, {},
              #         post.post_nodes.each_with_index.map do |post_node, i|
              #           break if i > 1
              #           render_post_node_depending_on_type(post_node.node, true)
              #         end
              #       ),
              #       t(:button, { onClick: ->{expand_to_read(post)} }, 'read more')
              #     )
              #   else
              #     t(:div, {},
              #       post.post_nodes.map do |post_node|
              #         render_post_node_depending_on_type(post_node.node)
              #       end
              #     )
              #   end,
              #   t(:div, {},
              #     #t(Components::PostKarmaTransactions::New, {post_karma_id: post.post_karma.id, post: post, on_post_karma_transaction_created: event(->(p_k_t, _post){on_post_karma_transaction_created(p_k_t, _post)})})
              #   )
              #)
            end,
            t(:div, {ref: 'last_beacon'},
              next_page_infinite_scroll_beacon(state.posts.data.length - 1)
            )
          )
        end

        #truncate_text : bool ; required for PostTexts::Show do add appropriate css class tha later will shorten the text via css styles
        #(to not litter with lengthy posts the index, if user wants to see all he just clicks so)
        def render_post_node_depending_on_type(node, truncate_text = false)
          case node
          when PostText
            t(Components::PostTexts::Show, {post_text: node, truncate_text: truncate_text})
          when PostImage
            t(Components::PostImages::Show, {post_image: node})
          when PostGif
            t(Components::PostGifs::Show, {post_gif: node})
          when VideoEmbed
            t(Components::VideoEmbeds::Show, {video_embed: node})
          end
        end


        def handle_infinite_croll_beacon_reach
          destroy_infinite_scroll_beacon
          fetch_and_set_posts(pagination_current_page + 1)

          # destroy_infinite_scroll_beacon
          # Post.index(extra_params: {page: (pagination_current_page + 1), per_page: state.per_page}).then do |posts|
        end

        # def expand_to_read(post)
        #   Post.show(wilds: {id: post.id}).then do |_post|
        #     begin
        #     post.attributes = _post.attributes
        #     post.attributes[:opened] = true
        #     set_state posts: state.posts
        #     rescue Exception => e
        #       p e
        #     end
        #   end
        # end
        def subscription_changed(user, user_subscription, status)
          case status
          when :unsubscribed
            user.usub_with_current_user = nil
            #iterates posts in order to set them so with updated subscription status
            #because each post may come with separate instances of one subscription entity
            #so if posts have the same author it should update subscribe component of each those posts
            state.posts.each do |post|
              if post.author.id == user.id
                post.author.usub_with_current_user = UserSubscription.new(to_user_id: user.id)
              end
            end
          when :subscribed
            user.usub_with_current_user = user_subscription
            state.posts.each do |post|
              if post.author.id == user.id
                post.author.usub_with_current_user = user_subscription
              end
            end
          end
          force_update
        end

        def pkt_changed(pkt)
          p "changed #{pkt}: #{pkt.attributes}"
          force_update
        end

        def component_will_unmount
          @@instance = nil
        end

        def no_posts_message
          if @is_at_dashboard
            t(:p, {}, 'you have not created posts yet')
          else
            t(:p, {}, 'ths user has not created posts yet')
          end
        end
        # def on_post_karma_transaction_created(p_k_t, post)
        #   post.post_karma.count += p_k_t.amount
        #   set_state posts: state.posts
        # end

      end
    end
  end
end
