module Components
  module Posts
    class Show < RW
      expose

      def get_initial_state
        post = props.post || false
        {
          post: post
        }
      end

      def component_will_receive_props(np)
        if cp = props.source_class.try(:current_post_for_show)
          set_state post: cp
        else
          if np.params.post_id != props.params.post_id
            fetch_post(np.params.post_id)
          end
        end
      end

      def component_did_mount

        if cp = props.source_class.try(:current_post_for_show)
          set_state post: cp
        elsif props.post
          set_state post: props.post
        else
          post_id = props.params.post_id
          fetch_post(post_id)
        end
      end


      def fetch_post(post_id)
        Post.show(wilds: {id: post_id}, component: self).then do |post|
          begin
          set_state post: post
          rescue Exception => e
            p e
            `console.log(#{e})`
          end
        end
      end




      def render
        t(:div, {className: 'post posts-show'},
          progress_bar,
          if n_state(:post)
            t(:div, {},
              t(:div, {className: 'post-head'},
                t(:div, {className: 'row post-title-and-karma-count'},
                  t(:h1, {className: 'post-title col-lg-9'},
                    n_state(:post).title
                  ),
                  t(:p, {className: 'post-karma-count col-lg-3'},
                    if !n_state(:post).post_karma.attributes[:hot_since] && !n_state(:post).post_karma.current_user_post_karma_transaction.try(:cancel_type)
                      t(:p, {className: 'freshnotifier'}, 'vote to get double karma!')
                    end,
                    t(:p, {className: 'karmaamount'}, "#{n_state(:post).post_karma.count}")
                  )
                )
              ), 
              t(:div, {className: 'author-date'},
                t(Components::Users::Partials::AuthorLabel, 
                  {
                    user: n_state(:post).author,
                    subscription_changed: (event(->(user, user_subscription, status){subscription_changed(user, user_subscription, status)}))
                  }
                ),
                t(:div, {className: 'date'},
                  `#{`new Date(#{n_state(:post).created_at})`}.toLocaleDateString('us-US', {day: 'numeric', month: 'long', year: '2-digit'})`
                )
              ),
              t(:div, {className: 'post-nodes'},
                n_state(:post).s_nodes.map do |post_node|
                  show_node_depending_on_type(post_node.node)
                end,
                t(:div, {className: 'tags'},
                  #TODO: post should serialize tags on self
                  state.post.post_tags.map do |pt|
                    if pt.name
                      pt.name
                    else
                      next
                    end
                  end
                )                
              ),
              t(Components::PostKarmaTransactions::New, 
                {
                  post_karma: n_state(:post).post_karma, 
                  pkt: n_state(:post).post_karma.current_user_pkt_or_new, 
                  pkt_changed: event(->(pkt){pkt_changed(pkt)})
                }
              ),
              t(:div, {className: 'discussions-block'},
                t(Components::Discussions::Show, {post_id: state.post.id, should_scroll_to_comments: should_scroll_to_comments})
              )
            )
          else
            nil
          end
        )
      rescue Exception => e

        p e
      end

      def should_scroll_to_comments
        if props.location
          if props.location.query[:scroll_to_comments]
            return true
          end
        else
          return false
        end
      end

      def subscription_changed(user, user_subscription, status)
        n_prop(:owner).subscription_changed(user, user_subscription, status) if n_prop(:owner)
      end

      def show_node_depending_on_type(node)
        case node
        when PostText
          t(Components::PostTexts::Show, {post_text: node})
        when PostImage
          t(Components::PostImages::Show, {post_image: node, show_source: true})
        when PostGif
          t(Components::PostGifs::Show, {post_gif: node})
        when VideoEmbed
          t(Components::VideoEmbeds::Show, {video_embed: node})
        when PostVotePoll
          t(Components::VotePolls::Show, {vote_poll: node})
        when PostTest
          if node.is_personality
            t(Components::PersonalityTests::Show, {post_test: node})
          else
            t(Components::PostTests::Show, {post_test: node, show_serialized_fields: true})
          end
        when MediaStory
          t(Components::MediaStories::Show, {media_story: node})
        end
      end


      def pkt_changed(pkt)
        force_update
        n_prop(:owner).pkt_changed(pkt)
      end



      # def on_post_karma_transaction_created(p_k_t, post)
      #   if n_state(:owner)
      #     n_state(:owner).on_post_karma_transaction_created(p_k_t, post)
      #   end
      #   state.post.post_karma.count += p_k_t.amount
      #   set_state post: state.post
      # end



    end
  end
end
