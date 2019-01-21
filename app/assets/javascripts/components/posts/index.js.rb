
module Components
  module Posts
    class Index < RW

      expose

      include Plugins::InfiniteScrollable

      @current_post_for_show

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
        #post.make_dirty
        self.class.current_post_for_show = post
      end

      #required to be able to access ref of ::ShowInline's html
      #when it's opened in show proxy, theres no direct access to it
      #accessing to showinline's html as ref is necessary, for
      #refactored TODO test and clean
      # def index_to_show_map
      #   @index_to_show_map
      # end

      # def ref_to_post_with_index(i)
      #   index_to_show_map[i].n_ref("post#{i}")
      # end

      def get_initial_state
        #to use in render denote some elements as mobile via css class
        #refactored TODO test and clean
        #@index_to_show_map = {}
        #@m_class = $IS_MOBILE ? 'm' : ''
        @post_index_query_running = false
        {
          posts: ModelCollection.new,
          per_page: 10,
          current_index_in_view: 0,
          fresh_already_shown: [],
          tiles_to_insert: {}
        }
      end

      def component_did_mount

        UserNotificationsManager.instance.subscribe(:when_notifications_updated, self)

        if props.location.pathname == "/posts/index" || props.location.pathname == "/"
          fetch_and_set_posts
        end
        if $IS_MOBILE
          p "is mobile"
          listen_attach_next_button_if_post_is_too_long
        end
      end

      #
      def when_notifications_updated
        if !@notifier_rendered
          @notifier_rendered = true
          n_state('tiles_to_insert')[n_state('posts').data.length - 1] = t(Components::UserNotifications::PostIndexIndex, {key: "#{n_state('posts').data.length - 1}nm", arbitrary_id: n_state('posts').data.length, owner: self})
          n_set_state `{tiles_to_insert: #{n_state('tiles_to_insert')}}`
        end
      end

      #this method is called from notifications-index if it was rendered
      #called through prop owner that is passed to it in #when_notifications_udpated
      def notifications_emptied(index_at_tiles_to_insert)
        @notifier_rendered = false
        n_state('tiles_to_insert').delete(index_at_tiles_to_insert)
        force_update
      end

      def component_will_receive_props(np)
        if np.location.pathname != props.location.path && state.posts.data.empty?
          fetch_and_set_posts
        end
      end

      def fetch_and_set_posts(page = 1)

        return if @post_index_query_running
        @post_index_query_running = true

        promise = Post.index(extra_params: {page: page, per_page: state.per_page}, component: self).then do |posts|
          begin
          extract_pagination(posts)

          shown_ids = []
          posts = posts.select do |post|
            if state.fresh_already_shown.include?(post.id)
              false
            else
              shown_ids << post.id
              true
            end
          end

          state.fresh_already_shown += shown_ids

          if posts.length < 1
            return nil
          end

          posts = posts.sort_by { |post| post.attributes[:created_at] }

          state.posts.data += posts

          set_state posts: state.posts, fresh_already_shown: state.fresh_already_shown
          listen_to_infinite_scroll_beacon

          @post_index_query_running = false

          # if !@in_view_checker_interval
          #   @in_view_checker_interval = Services::Interval.new(500) { check_in_view_and_set_if_not }
          #   @in_view_checker_interval.start
          # end
          # @first_offset ||= ref("post0").offsetTop
          #next_beacon(state.current_index_in_view)
          if page == 1 && $IS_MOBILE
            listen_for_current_post_in_view
          end
          rescue Exception => e
            p e
          end
        end

      end



      def listen_attach_next_button_if_post_is_too_long
        x = `$(window).width() / 3`
        y = `$(window).height() / 5`
        @attach_next_button_if_post_is_too_long = Services::Interval.new(650) do
          if pi = post_div_element_at_coords(x, y)
            #if `#{n_ref("post#{pi}")}.offsetHeight > #{y * 5}`
            if pi.JS[:offsetHeight] > y * 5
              unless n_state(:next_post_helper)
                set_state next_post_helper: true, next_post_helper_top: pi.JS.getBoundingClientRect().JS[:right]
              end
            else
              if n_state(:next_post_helper)
                set_state next_post_helper: false
              end
            end
          end
        end

        @attach_next_button_if_post_is_too_long.start
      end

      def unlisten_attach_next_button_if_post_is_too_long
        if $IS_MOBILE
          @attach_next_button_if_post_is_too_long.stop
          @attach_next_button_if_post_is_too_long = nil
        end
      end


      def scroll_to_next_post
        x = `$(window).width() / 3`
        y = `$(window).height() / 5`
        if pi = post_div_element_at_coords(x,y)
          `
          console.log(($(#{pi}).data('post-index') + 1))
          var nextPost = $(".post[data-post-index='" + ($(#{pi}).data('post-index') + 1) )[0];
          console.log(nextPost);
          var valueToIncrementScrollTop = nextPost.getBoundingClientRect().top;
          //fucking ie; god damn it even the latest versions cause shit like this to happen!
          if (document.documentElement && document.documentElement.scrollTop) {
            document.documentElement.scrollTop += valueToIncrementScrollTop
          } else {
            document.body.scrollTop += valueToIncrementScrollTop
          }
          `
        end
      end

      def render_posts
        length_availability = (@length - @current_index)
        if  length_availability > 5
          [
            render_r1c3,
            render_r1c2
          ]
        elsif length_availability > 3
          [
            render_r1c3
          ]
        elsif length_availability > 2
          [
            render_r1c2
          ]
        elsif length_availability > 1
          [
            render_r1c1
          ]
        else
          @current_index += 1
          []
        end
      end

      def render_r1c3
        t(Components::Posts::Grids::R1c3, {},
          tile_or_post,
          tile_or_post,
          tile_or_post
        )
      end

      def render_r1c2
        t(Components::Posts::Grids::R1c2, {},
          tile_or_post,
          tile_or_post
        )
      end

      def render_r1c1
        tile_or_post
        # (@current_index += 1
        # t(Components::Posts::ShowInline, {post: n_state('posts').data[@current_index], owner: self, i: @current_index, key: @current_index}))
      end

      def tile_or_post
        if n_state('tiles_to_insert')[@current_index] && @repeating_index != @current_index
          @repeating_index = @current_index
          n_state('tiles_to_insert')[@current_index]
        else
          @repeating_index = nil
          (
            @current_index += 1
            is_current = nil
            if n_state(:current_index_in_view) == @current_index
              is_current = 'current'
            end
            t(Components::Posts::ShowInline, 
              {
                post_link_part: '', 
                is_current: is_current, 
                post: n_state('posts').data[@current_index], 
                owner: self, 
                i: @current_index, 
                key: @current_index
              }
            )
          )
        end
      end




      def render
        @length = n_state('posts').data.length
        @current_index = -1
        t(:div, {className: 'posts-index'},
          
          children,

          # #listen_attach_next_button_if_post_is_too_long attaches checker if post at middle of screen is longer than screen
          # if it is state[:next_post_helper] set to true;
          if n_state(:next_post_helper)
            t(:button, {className: 'btn btn-xs', style: {position: 'fixed', left: n_state(:next_post_helper_top)}.to_n, onClick: ->{scroll_to_next_post}}, 'next')
          end,

          if props.params.post_id && props.location.pathname == "/#{props.params.post_id}"
            t(Components::Posts::ShowProxy, {owner: self, location: props.location, params: props.params, history: props.history})
          end,
          if @length > 0
            res = []
            while @current_index < @length do
              res += render_posts
            end
            # 2.times do
            #   res += render_posts
            # end
            res
          end,

          progress_bar,

          #state.posts.each_with_index.map do |post, i|
            #var to be included in className of el
            #t(Components::Posts::ShowInline, {owner: self, post: post, i: i, key: i})
            # is_current = ""
            # if i == state.current_index_in_view
            #   is_current = "current"
            # end
            # ######
            # t(:div, {ref: "post#{i}", "data-post-index" => i, className: "#{@m_class} post #{is_current}"},
            #   t(:div, {className: 'post-head'},
            #     t(:div, {className: 'row post-title-and-karma-count'},
            #       t(:h1, {className: 'post-title col-lg-9', onClick: ->{set_current_post_for_show(post)} }, link_to("#{post.title}", "/#{post.id}")),
            #       t(:p, {className: 'post-karma-count col-lg-3'},
            #         if !post.post_karma.attributes[:hot_since] && !post.post_karma.current_user_post_karma_transaction
            #           t(:p, {className: 'freshnotifier'}, 'vote to get double karma!')
            #         end,
            #         t(:p, {className: 'karmaamount'}, "#{post.post_karma.count}")
            #       )
            #     )
            #     #,
            #     # t(:div, {className: 'post-author'},
            #     #   link_to(" #{post.author.user_credential.name}", "/users/#{post.author.id}")
            #     # )
            #   ),
            #   t(:div, {className: 'post-body'},
            #     if !post.attributes[:opened]
            #       truncated = should_truncate?(post) ? 'truncated' : nil
            #       [
            #       t(:div, {className: "post-nodes #{truncated}"},
            #         post.post_nodes.map do |post_node|
            #           render_post_node_depending_on_type(post_node.node)
            #         end
            #       ),
            #       if truncated
            #         t(:div, {className: 'post-expander'},
            #           count_elements_disclaimer(post.post_nodes),
            #           t(:button, { onClick: ->{expand_to_read(post)} }, 'more fun in here')
            #         )

            #       end
            #       ]
            #     else
            #       t(:div, {className: 'post-nodes'},
            #         post.post_nodes.map do |post_node|
            #           render_post_node_depending_on_type(post_node.node)
            #         end
            #       )
            #     end,

            #   ),
            #   if !$IS_MOBILE
            #     bottom_lane_for_post_controll(post)
            #   end
            # )
          #end,
          t(:p, {ref: "last_beacon"},
            next_page_infinite_scroll_beacon(state.posts.data.length - 1)
          ),
          #becouse current in view depends on reaching some point on screen
          #if no more post beneath the last ones they will be unable to reach that point
          #so this blank div with screen height is added
          t(:div, {style: {height: $CLIENT_HEIGHT}.to_n}),
          if $IS_MOBILE
            t(:div, {className: 'row post-controll-row'},
              t(:div, {className: 'col-lg-8 post-controll'},
                if post = state.posts.data[state.current_index_in_view]
                  t(:div, {className: ''},
                    t(:div, {className: 'top-lane'},
                      t(:p, {className: 'preview-name'}, post.title),
                      t(:p, {className: 'post-karma-count'}, "#{post.post_karma.count}"),
                      t(:p, {className: 'author-name'}, post.author.user_credential.name)
                    ),
                    bottom_lane_for_post_controll(post)
                  )
                end
              ),
              t(:div, {className: 'col-lg-4'})
            )
          end
        )
      end

      # def should_truncate?(post)
      #   if post.post_nodes.data.length > 1
      #     true
      #   elsif post.post_nodes[0].node.is_a?(PostText) && post.post_nodes[0].node.content.length > 200
      #     true
      #   end
      # end

      # def count_elements_disclaimer(post_nodes)
      #   images = 0
      #   videos = 0
      #   text = 0
      #   post_nodes.each do |post_node|
      #     case post_node.node
      #     when PostImage
      #       images += 1
      #     when VideoEmbed
      #       videos += 1
      #     when PostText
      #       text += 1
      #     end
      #   end
      #   [
      #     if videos > 0
      #       "videos: #{videos}"
      #     end,
      #     if images > 0
      #       "images: #{images}"
      #     end,
      #     if text > 0
      #       "text"
      #     end
      #   ]
      # end
      #Gives controll on post for mobile devices; to be rendered as fixed at bottom.
      def bottom_lane_for_post_controll(post)
        t(:div, {className: 'bottom-lane'},
          t(:ul, {},
            t(:li, {},
              t(Components::UserSubscriptions::CreateOrShow, {
                                    user_to_subscribe_to: post.author,
                                    user_subscription: ((_ = post.author.usub_with_current_user) ? _ : UserSubscription.new),
                                    subscription_changed: (event(->(user, user_subscription, status){post.make_dirty ; subscription_changed(user, user_subscription, status)}))
                                  }
              )
            ),
            link_to(
              t(:li, {onClick: ->{set_current_post_for_show(post)} },

                  t(:i, {className: 'icon-comment-empty'})

              ),
              "/#{post.id}"
            ),
            #t(:li, { onClick: ->{scroll_to_next(state.current_index_in_view + 1)} }, "next"),
            t(:li, {},
              t(Components::PostKarmaTransactions::New, 
                {
                  post_karma: post.post_karma, 
                  pkt: post.post_karma.current_user_pkt_or_new, 
                  pkt_changed: event(->(pkt){pkt_changed(pkt, post.author.id)})
                }
              )
            )
          )
        )
      end

      #this method is passed as event to UserCusbscription component
      #user : User
      #user_subscription : UserSubscription
      #status : Symbol(:subscribed) || Symbol(:unsubscribed)
      def subscription_changed(user, user_subscription, status)
        p "posts/index #subscription_changed called"
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


      def scroll_to_next(index)
        if state.posts.data.length > index

          el = n_ref("post#{index}")
          puts "index - #{index}"
          `console.log(#{el}.getBoundingClientRect().top)`

          #`$(document.body).prepend($("<div style='position: fixed; top:" + #{el}.getBoundingClientRect().top + "px; border-top: thin solid black; width: 100%;'>FOOO</div>"))`

           `
          function scrollTo(element, to, duration) {

              element.scrollTop += to
              /*if (duration <= 0) return;
              var difference = to - element.scrollTop;
              var perTick = difference / duration * 10;

              setTimeout(function() {
                  element.scrollTop += perTick;
                  if (element.scrollTop === to) {
                    return
                  };
                  scrollTo(element, to, duration - 10);
              }, 10);*/
          };
          scrollTo(document.body, #{el}.getBoundingClientRect().top - #{@height_at_which_post_is_considered_current} + 1, 50);
          `
        end
      end



      def set_first_in_view
        # i = -1
        # n_refs_each do |k, v|
        #   if k.JS.substring(0, 4) == "post"
        #     i += 1
        #     if Services::JsHelpers.is_element_in_viewport?(v)
        #       next_beacon(i)
        #     end
        #   end
        # end
      end

      #sets height at wich post will be counted as 'in view'
      #if first post is less than half of viewport it's bottom will serve as that point
      #for perf reasons uses timeout
      # def add_line_at(name, px)
      #   `$(document.body).prepend($("<div style='position: fixed; top:" + px + "px; border-top: thin solid black; width: 100%;'>" + #{name} + "</div>"))`
      # end

      def listen_for_current_post_in_view
        `
          var $firstPost = $('.current').first()[0];

          if((typeof $firstPost) != 'undefined') {

            var $window = $(window);
            var windowHeight = $window.height();
            var pixelsFromLeft = $window.width() / 3;
            var firstPostBottom = $firstPost.getBoundingClientRect().bottom;
            var pixelsFromTop = 0;

            if (firstPostBottom > (windowHeight / 2)) {
              pixelsFromTop = ((windowHeight / 3));
            } else {
              pixelsFromTop = firstPostBottom - 3;
            };

            //adds element pointer wich will hint user wich post is current
            $currentPostPointer = $("<div class='post-pointer' style='position: fixed; z-index: 10; top:" + pixelsFromTop + "px'></div>");
            $(document.body).prepend($currentPostPointer);

            //#sets attribute to be used in class later (e.g. in scroll to post and etc)
            #{@height_at_which_post_is_considered_current = `pixelsFromTop`}



            var isScrolling = false;

            $(document).on('scroll.postInView', function(){

              if (isScrolling) {

                return;

              } else {

                isScrolling = true;

                setTimeout(function(){
                  isScrolling = false;

                  #{

                    if pi = post_index_at_coords(`pixelsFromLeft`, `pixelsFromTop`)
                      unless  "#{pi}" == "#{n_state(:current_index_in_view)}"
                        set_state current_index_in_view: pi
                      end
                    end

                  }

                }, 100)

              }

            })

          };

        `
      end

      def post_index_at_coords(x, y)
        `
          var elementAtCoordinates = $(document.elementFromPoint(#{x}, #{y}));
          var closestPost = $(elementAtCoordinates.closest('.post'));

          if (closestPost[0]) {
            var postIndex = closestPost.data('post-index');
            return postIndex
          } else {
            return #{false};
          };
        `
      end

      def post_div_element_at_coords(x, y)
        %x{
          var elementAtCoordinates = $(document.elementFromPoint(#{x}, #{y}));
          var closestPost = $(elementAtCoordinates.closest('.post'));
          if (closestPost[0]) {
            return closestPost[0]
          } else {
            return #{false};
          };
        }
      end

      def unlisten_for_current_post_in_view
        `
          $(document).off('scroll.postInView');
        `
      end

      def next_beacon(i = 0)
        # if @current_beacon
        #   @current_beacon.destroy
        # end
        # if @previous_beacon
        #   @previous_beacon.destroy
        # end

        # set_state(current_index_in_view: i)

        # @previous_beacon = Waypoint.new(
        #   element: ref("post#{i}"),
        #   handler: ->(direction){
        #     if direction == 'up'
        #       next_beacon(i - 1)
        #     end
        #   },
        #   offset: "#{@first_offset + 50}px"
        # ) if ref("post#{i}")

        # @current_beacon = Waypoint.new(
        #   element: ref("post#{i + 1}"),
        #   handler: ->(direction){
        #     if direction == 'down'
        #       #set_state(current_index_in_view: i+1)
        #       next_beacon(i+1)
        #     end
        #   },
        #   offset: "#{@first_offset + 50}px"
        # ) if ref("post#{i+1}")
      end

      #truncate_text : bool ; required for PostTexts::Show do add appropriate css class tha later will shorten the text via css styles
      #(to not litter with lengthy posts the index, if user wants to see all he just clicks so)
      # def render_post_node_depending_on_type(node, truncate_text = false)
      #   case node
      #   when PostText
      #     t(Components::PostTexts::Show, {post_text: node, truncate_text: truncate_text})
      #   when PostImage
      #     t(Components::PostImages::Show, {post_image: node})
      #   when PostGif
      #     t(Components::PostGifs::Show, {post_gif: node})
      #   when VideoEmbed
      #     t(Components::VideoEmbeds::Show, {video_embed: node})
      #   end
      # end


      def handle_infinite_croll_beacon_reach
        destroy_infinite_scroll_beacon
        fetch_and_set_posts(pagination_current_page + 1)
        # Post.index(extra_params: {page: (pagination_current_page + 1), per_page: state.per_page}).then do |posts|

        #   if posts.data[0].attributes[:pagination]
        #     return
        #   end

        #   extract_pagination(posts)
        #   state.posts.data += posts.data
        #   set_state posts: state.posts
        #   listen_to_infinite_scroll_beacon

        # end
      end

      def expand_to_read(post)
        post.make_dirty
        post.attributes[:opened] = true
        set_state posts: state.posts
        # Post.show(wilds: {id: post.id}).then do |_post|
        #   post.make_dirty
        #   begin
        #   post.attributes = _post.attributes
        #   post.attributes[:opened] = true
        #   set_state posts: state.posts
        #   rescue Exception => e
        #     p e
        #   end
        # end
      end

      def check_in_view_and_set_if_not
        if Services::JsHelpers.is_element_out_of_viewport?(n_ref("post#{state.current_index_in_view}"))
          set_first_in_view
        end
      end

      # def on_post_karma_transaction_created(p_k_t, post)
      #   #post.make_dirty
      #   post.post_karma.current_user_post_karma_transaction = p_k_t
      #   post.post_karma.count += p_k_t.amount
      #   set_state posts: state.posts
      # end 

      def pkt_changed(pkt, post_author_id)
        amount_to_increment_on = pkt.amount_change_factor * Services::KarmaManager::WHEN_LIKED_OR_DISLIKED_THIS_USERS_POST
        n_state(:posts).each do |post|
          if post.author.id == post_author_id 
            post.author.user_karma.count += amount_to_increment_on
          end
        end
        force_update
      end

      def component_will_unmount
        self.class.clear_current_post_for_show
        UserNotificationsManager.instance.unsubscribe(:when_notifications_updated, self)
        unlisten_for_current_post_in_view
        unlisten_attach_next_button_if_post_is_too_long
        `$('.post-pointer').remove()`
      end

    end
  end
end
