module Components
  module Staff
    module UserSubmitted


        module Posts

          class Index < RW


            expose

            include Plugins::Formable
            include Plugins::InfiniteScrollable

            def get_initial_state
              {
                post_search_object: Post.new,
                posts: ModelCollection.new,
                per_page: 10
              }
            end

            def component_did_mount
              fetch_and_set_posts
            end

            def fetch_and_set_posts
              perform_search(page: 1)
              # Post.index(namespace: 'staff/user_submitted/unpublished', extra_params: {page: 1, per_page: state.per_page}).then do |posts|
              #   begin
              #   extract_pagination(posts)
              #   set_state posts: posts
              #   listen_to_infinite_scroll_beacon
              #   rescue Exception => e
              #     p e
              #   end
              # end
            end

            def render
              t(:div, {},
                modal,
                t(:div, {},
                  input(Components::Forms::Input, state.post_search_object, :fulltext, {namespace: 'search_object', show_name: 'fulltext search'}),
                  input(Components::Forms::Input, state.post_search_object, :title, {namespace: 'search_object', show_name: 'search by title'}),
                  input(Components::Forms::PlainCheckbox, state.post_search_object, :published, {namespace: 'search_object', show_name: 'search published'}),
                  input(Components::Forms::PlainCheckbox, state.post_search_object, :unpublished, {namespace: 'search_object', show_name: 'search unpublished'}),
                  input(Components::Forms::Input, state.post_search_object, :by_user_name, {namespace: 'search_object', show_name: 'by user name'}),
                  (
                  _s_o = Forms::Services::SelectOption
                  @_preselected ||= _s_o.new('desc', 'desc')
                  @_select_options = [@_preselected, _s_o.new('asc', 'asc')]
                  input(Components::Forms::PlainSingleSelect, state.post_search_object, :order, {namespace: 'search_object', show_name: 'set order', select_options: @_select_options, preselected_option: @_preselected})
                  ),
                  t(:button, { onClick: ->{perform_search({page: 1, flush: true})} }, 'search')
                ),
                state.posts.map do |post|
                  t(:div, {},
                    t(:div, {},
                      if post.title
                        t(:h1, {}, link_to("#{post.title} # #{post.id}", "/posts/#{post.id}"))
                      end,
                      t(:button, {onClick: ->{init_post_editing(post)}},
                        'edit'
                      ),
                      if post.attributes[:published]
                        t(:div, {},
                          "published on #{post.attributes[:published_at]}",
                          t(:button, {onClick: ->{unpublish_post(post)}}, 'unpublish this')
                        )
                      else
                        t(:div, {},
                          t(:button, { onClick: ->{publish_post(post)} }, 'publish this')
                        )
                      end,
                      post.post_nodes.map do |post_node|
                        render_post_node_depending_on_type(post_node.node)
                      end
                    ),
                    t(:div, {},
                      t(:p, {}, "post karma: #{post.post_karma.count}"),
                      t(Components::PostKarmaTransactions::New, {post_karma: post.post_karma, pkt: post.post_karma.current_user_pkt_or_new, pkt_changed: event(->(pkt){pkt_changed(pkt)})})
                    )
                  )
                end,
                next_page_infinite_scroll_beacon
              )
            end

            def pkt_changed(pkt)
              force_update
            end


            def render_post_node_depending_on_type(node)
              case node
              when PostText
                t(Components::PostTexts::Show, {post_text: node})
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
              perform_search(page: (pagination_current_page + 1), flush: false)
              # Post.index(extra_params: {page: (pagination_current_page + 1), per_page: state.per_page}).then do |posts|
              #   if posts.data[0].attributes[:pagination]
              #     return
              #   end
              #
              #   extract_pagination(posts)
              #   state.posts.data += posts.data
              #   set_state posts: state.posts
              #   listen_to_infinite_scroll_beacon
              #
              # end
            end


            def on_post_karma_transaction_created(p_k_t, post)
              post.post_karma.count += p_k_t.amount
              set_state posts: state.posts
            end

            def publish_post(post)

              post.set_published(namespace: 'staff/user_submitted/unpublished/', wilds: {id: post.id}).then do |_post|
                begin
                post.attributes[:published] = true
                post.attributes[:published_at] = _post[:post][:published_at]
                set_state posts: state.posts
                rescue Exception => e
                  p e
                end
              end
            end


            def unpublish_post(post)
              post.set_unpublished(namespace: 'staff/user_submitted/unpublished', wilds: {id: post.id}).then do |_post|
                post.attributes[:published] = false
                post.attributes[:published_at] = nil
                set_state posts: state.posts
              end
            end



            def perform_search(options = {}) #avaliable options flush : Bool, page : Int

              collect_inputs(namespace: 'search_object', form_model: 'post_search_object')
              state.post_search_object.perform_search(namespace: "staff", extra_params: {page: options[:page], per_page: state.per_page}).then do |posts|
                begin
                extract_pagination(posts)

                posts.data.uniq! {|post| post.id}

                # posts.each do |post|
                #   post.sort_nodes_in_order
                # end

                if options[:flush] == true
                  state.posts.data = posts.data
                else
                state.posts.data += posts.data
                end


                set_state posts: state.posts

                listen_to_infinite_scroll_beacon unless posts.data.empty?
                rescue Exception => e
                  p e
                end
              end
            end




            def init_post_editing(post)
              modal_open(
                "editing post # #{post.id}",
                t(Components::Staff::Posts::Edit, {post: post, on_edit_done: event(->(post){on_edit_done(post)})})
              )
            end


            def on_edit_done(post)
              modal_close
              state.posts.each do |_post|
                if _post.id == post.id
                  p 'found'
                  _post.attributes = post.attributes
                  break
                end
              end
              set_state posts: state.posts
            end

          end

        end


    end
  end
end
