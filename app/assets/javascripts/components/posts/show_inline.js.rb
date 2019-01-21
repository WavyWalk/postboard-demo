module Components
  module Posts
    class ShowInline < RW
      expose

      def validate_props
        # rquired props:
        # post : Post
        # owner : RW
        # i : Integer #index of post in array on owner
        #optional
        #post_preceding_link : String # part of url to be added before link_to #{post_preceding_link}/post.id
        #owner must implement
        #subscription_changed(user, user_subscription, status) #to propagate
        #def pkt_changed(pkt)
        #n_prop(:owner).pkt_changed(pkt)
        #set_current_post_for_show(post)
      end

      # def __should_component_update__(np, ns)
      #   np.JS[:post].dirty?
      # end
      def init
        if n_prop(:post_link_preceding_part)
          @post_link_preceding_part = n_prop(:post_link_preceding_part)
        else
          @post_link_preceding_part = ''
        end
      end


      def component_did_mount
        #refactored
        #n_prop(:owner).index_to_show_map[n_prop(:i)] = self
      end

      def render
        post = n_prop(:post)
        i = n_prop(:i)
        if post
          t(:div, {ref: "post#{i}", "data-post-index" => i, className: "#{$DISPLAY_SIZE} post #{n_prop(:is_current)}"},
            
            t(:div, {className: 'post-head'},
              t(:div, {className: 'row post-title-and-karma-count'},
                t(:h1, {className: 'post-title col-lg-9', onClick: ->{set_current_post_for_show(post)} }, link_to(post.title, "#{@post_link_preceding_part}/#{post.id}")),
                t(:p, {className: 'post-karma-count col-lg-3'},
                  if !post.post_karma.attributes[:hot_since] && !post.post_karma.current_user_post_karma_transaction.try(:cancel_type)
                    t(:p, {className: 'freshnotifier'}, 'vote to get double karma!')
                  end,
                  t(:p, {className: 'karmaamount'}, "#{post.post_karma.count}")
                )
              )
              #,
              # t(:div, {className: 'post-author'},
              #   link_to(" #{post.author.user_credential.name}", "/users/#{post.author.id}")
              # )
            ),
            t(:div, {className: 'post-body'},
              if !post.attributes[:opened]
                truncated = should_truncate?(post) ? 'truncated' : nil
                [
                t(:div, {className: "post-nodes #{truncated}"},
                  post.s_nodes.map do |post_node|
                    render_post_node_depending_on_type(post_node.node)
                  end
                ),
                if truncated

                  #t(:div, {className: ''},
                    link_to(
                      t(:div, {onClick: ->{set_current_post_for_show(post)}, className: 'read-more post-expander'},
                        count_elements_disclaimer(post.s_nodes),
                        "more...",
                        t(:i, {className: "icon-window-restore"})
                      ), #{ onClick: ->{expand_to_read(post)} }, 'more fun in here'),
                      "#{@post_link_preceding_part}/#{post.id}"
                    )
                  #)

                end
                ]
              else
                t(:div, {className: 'post-nodes'},
                  post.s_nodes.map do |post_node|
                    render_post_node_depending_on_type(post_node.node)
                  end
                )
              end

            ),

            if !$IS_MOBILE
              #n_prop(:owner).bottom_lane_for_post_controll(post)
              bottom_lane_for_post_controll(post)
            end
          )
        else
          ''
        end
      end



      def bottom_lane_for_post_controll(post)
        date = `new Date(#{post.created_at})`
        t(:div, {className: 'bottom-lane'},
          t(:ul, {},
            t(:li, {className: 'date'},
              `#{date}.toLocaleDateString('us-US', {day: 'numeric', month: 'long', year: '2-digit'})`
            ),            
            t(:li, {},
              if post.author
                t(Components::Users::Partials::AuthorLabel, 
                  {
                    user: post.author,
                    subscription_changed: (event(->(user, user_subscription, status){post.make_dirty ; subscription_changed(user, user_subscription, status)}))
                  }
                )
              end
            ),
            link_to(
              t(:li, {onClick: ->{set_current_post_for_show(post)} },

                  t(:i, {className: 'icon-comment-empty zoom'}),
                  if post.discussion
                    post.discussion.messages_count
                  end
              ),
              "/#{post.id}", {scroll_to_comments: true}
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


      def subscription_changed(user, user_subscription, status)
        n_prop(:owner).subscription_changed(user, user_subscription, status)
      end

      def pkt_changed(pkt, user_id)
        n_prop(:owner).pkt_changed(pkt, user_id)
      end

      def set_current_post_for_show(post)
        n_prop(:owner).set_current_post_for_show(post)
      end

      # def expand_to_read(post)
      #   n_prop(:owner).expand_to_read(post)
      # end

      def should_truncate?(post)
        if post.s_nodes.data.length > 1
          true
        elsif post.s_nodes[0].node.is_a?(PostText) && post.s_nodes[0].node.content.length > 200
          true
        elsif post.s_nodes[0].node.is_a?(PostTest)
          true
        end
      end

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
        when PostVotePoll
          t(Components::VotePolls::Show, {vote_poll: node, show_inline: true})
        when PostTest
          if node.is_personality
            t(Components::PersonalityTests::Show, {post_test: node})
          else
            t(Components::PostTests::ThumbShow, {post_test: node})
          end
        when MediaStory
          t(Components::MediaStories::Show, {media_story: node})
        end
      end

      def count_elements_disclaimer(post_nodes)
        images = 0
        videos = 0
        text = 0
        post_tests = 0
        post_nodes.each do |post_node|
          case post_node.node
          when PostImage
            images += 1
          when VideoEmbed
            videos += 1
          when PostText
            text += 1
          when PostTest
            post_tests += 1
          end
        end
        t(:div, {},
          if videos > 0
            t(:span, {className: 'item'},
              videos,
              t(:i, {className: 'icon-youtube-play'})
            )
          end,
          if images > 0
            t(:span, {className: 'item'},
              images,
              t(:i, {className: 'icon-picture'})
            )
          end,
          if text > 0
            t(:span, {className: 'item'},
              t(:i, {className: 'icon-doc-text'})
            )
          end,
          if post_tests > 0
            t(:span, {className: 'item'},
              post_tests,
              t(:i, {className: 'icon-help'})
            ) 
          end
        )
      end

    end
  end
end
