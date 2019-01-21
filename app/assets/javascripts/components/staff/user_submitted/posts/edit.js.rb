module Components
  module Staff
    module Posts
      class Edit < RW

        expose

        include Plugins::Formable

        def get_initial_state
          @current_edited_node_position = false
          @current_edited_node_position_for_thumb = false
          {
            post: false,
            changing_position: false,
            post_thumb_expanded: false,
            changing_position_for_thumb: false,
            post_images_in_roster: ModelCollection.new,
            insert_toolbar_before: {}
          }
        end


        def component_did_mount
          Post.edit(namespace: 'staff/user_submitted', wilds: {id: props.post.id}, component: self).then do |post|
            begin
            post.sort_post_nodes_in_order_as_in_s_nodes
            set_state post: post
            rescue Exception => e
              `console.log(e)`
            end
          end
        end

        def render
          post = n_state(:post)

          t(:div, {className: 'posts-new'},
            modal,
            if post
            [
              
              general_errors_for(state.post),

              t(:div, {className: 'input-and-button'},
                t(:p, {}, "title: "),
                input(Components::Forms::Input, post, :title, 
                  {
                    show_name: 'title', 
                    on_change: ->{handle_title_change},
                    namespace: 'title'
                  }
                ),
                if post.attribute_was_changed?(:title)
                  t(:button, {className: 'btn btn-primary btn-sm', onClick: ->{update_title}}, 
                    'update title'
                  )
                end
              ),

              t(:div, {className: 'input-and-button'},
                t(:p, {}, "karma: "),
                input(Components::Forms::Input, post.post_karma, :count, 
                  {
                    show_name: 'karma', 
                    namespace: 'karma_count',
                    on_change: ->{handle_karma_change}
                  }
                ),
                if post.post_karma.attribute_was_changed?(:count)
                  t(:button, {className: 'btn btn-primary btn-sm', onClick: ->{change_karma}}, 'set new karama count')
                end
              ),

              if n_state(:post).post_nodes.data.length < 1 && !n_state(:insert_toolbar_before)[1]
                controll_toolbar(-1)
              end,

              state.post.post_nodes.each_with_index.map do |post_node, i|
                [
                  if n_state(:insert_toolbar_before)[i]
                    controll_toolbar(i - 1)
                  end,
                  t(:div, {key: i, className: 'node-wrapper'},
                    t(:div, {className: 'node-and-controlls'},

                      t(:div, {className: 'top-controlls'},
                        if n_state(:insert_toolbar_before)[i]
                          t(:button, {className: 'btn btn-xs btn-default', onClick: ->{clear_insert_toolbar_before(i)}}, "-")
                        else
                          t(:button, {className: 'btn btn-xs btn-default', onClick: ->{set_insert_toolbar_before(i)} }, "+")
                        end,
                        t(:div, {className: 'right-group'},
                          if state.changing_position && i != -1
                            t(:button, {onClick: ->{paste_at_position(i)}, className: 'btn btn-sm btn-default' }, 'paste here')
                          else
                            unless i == 0
                              t(:button, {onClick: ->{init_change_index_position(i)}, className: 'btn btn-sm btn-default' }, 'cut')
                            end
                          end,
                          t(:button, {className: 'btn btn-xs btn-danger', onClick: ->{remove_node(i)}}, "X")
                        )
                      ),

                      t(:div, {className: 'node-body'},
                        if errors = post_node.node.errors[:general]
                          t(:div, {className: 'invalid'},
                            errors.each do |error|
                              t(:p, {}, error)
                            end
                          )
                        end,

                        view_node(post_node)
                      )
                    ),

                    if i == n_state(:post).post_nodes.data.length - 1
                      controll_toolbar(i)
                    end
                  )
                ]
              end,

              t(:div, {className: 'post-type'},
                if x = state.post.errors[:post_type]
                  t(:div, {className: 'invalid'},
                    x
                  )
                end,
                input(Components::Forms::SelectFromLabels, state.post, :post_type,
                  {
                    parsing_model: PostType,
                    show_value: 'alt_name',
                    url_feed: PostType.url_for_feed,
                    show_name: 'what this post is about?',
                    required_field: true
                  }
                )
              ),

              t(:div, {className: 'tag-controll row'},
                input(Components::Forms::MultipleSelectAutocompleWithTypeInput, state.post, :post_tags,
                  {
                    optional_field: true,
                    show_attribute: 'name', parsing_model: 'PostTag',
                    autocomplete_url: '/post_tags/autocompletes'
                  }
                )
              )
            ] 
          end
          )
        end

        #toolbar is added after each node, which is used for adding node components in specified order (position)
        def controll_toolbar(position)
          nodes = n_state(:post).post_nodes
          #return nil if n_state(:post).post_nodes.data.length < 1
          t(:div, {className: 'controll-toolbar'},
            if !(nodes[position].try(:node_type) == 'PostText') && !(position == -1 && nodes[position].try(:node_type) == "PostText")
              t(:button, {onClick: ->{init_post_text_addition(position)}, className: 'btn btn-sm btn-default' }, 'add text')
            end,
            t(:button, {onClick: ->{init_image_insertion(position)}, className: 'btn btn-sm btn-default' }, 'add image'),
            t(:button, {onClick: ->{init_gif_insertion(position)}, className: 'btn btn-sm btn-default' }, 'add gif'),
            t(:button, { onClick: ->{ init_video_embed(position) }, className: 'btn btn-sm btn-default' }, 'embed video'),
            t(:button, { onClick: ->{ init_vote_poll_insertion(position) }, className: 'btn btn-sm btn-default' }, 'add voting'),
            t(:button, { onClick: ->{ init_post_test_insertion(position) }, className: 'btn btn-sm btn-default' }, 'add test'),
            t(:button, { onClick: ->{ init_personality_test_insertion(position) }, className: 'btn btn-sm btn-default'}, 'add personality test'),
            t(:button, { onClick: ->{ init_media_story_insertion(position) }, className: 'btn btn-sm btn-default' }, 'add media story')
          )
        end

        # TOOLBAR POSITIONING 
        def set_insert_toolbar_before(index)
          set_state insert_toolbar_before: {index => true}
        end


        def clear_insert_toolbar_before(index)
          insert_toolbar_before = {}
          set_state insert_toolbar_before: insert_toolbar_before
        end
        #TOOLBAR POSITIONING

        #post text
        def init_post_text_addition(position)
          clear_insert_toolbar_before(@current_edited_node_position)
          @current_edited_node_position = position

          modal_open(
            nil,
            t(Components::PostTexts::New, 
              {
                on_done: ->(post_node){insert_node(post_node)},
                on_collect: ->(post_text, component){generic_create_node(post_text, component)}
              }
            )
          )
        end
        #post_text

        #image 
        def init_image_insertion(position)
          clear_insert_toolbar_before(@current_edited_node_position)
          @current_edited_node_position = position


          modal_open(
            nil,
            t(:div, {},
              t(Components::PostImages::New, 
                {
                  on_image_selected: event(->(image){insert_image_component(image)}), 
                  post_images: [],
                  on_collect: ->(post_image, component){generic_create_node(post_image, component)}
                } 
              )
            )
          )
        end

        #/ image

        #VIDEO EMBED
        def init_video_embed(position)
          clear_insert_toolbar_before(@current_edited_node_position)
          @current_edited_node_position = position

          video_embed = VideoEmbed.new

          modal_open(
            nil,
            t(Components::VideoEmbeds::New, 
              {
                video_embed: video_embed,
                on_collect: ->(video_embed, component){generic_create_node(video_embed, component)}
              }
            )
          )
        end

        #/ VIDEO EMBED


        #VOTE POLL
        def init_vote_poll_insertion(position)
          clear_insert_toolbar_before(@current_edited_node_position)
          @current_edited_node_position = position

          post_vote_poll = PostVotePoll.new

          modal_open(
            nil,
            t(Components::VotePolls::New, 
              {
                post_vote_poll: post_vote_poll,
                on_collect: ->(post_vote_poll, component){generic_create_node(post_vote_poll, component)}
              }
            )
          )         
        end

        #/ VOTE POLL

        # POST TEST
        def init_post_test_insertion(position)
          clear_insert_toolbar_before(@current_edited_node_position)
          @current_edited_node_position = position

          post_test = PostTest.new

          modal_open(
            nil,
            t(Components::PostTests::New, 
              {
                post_test: post_test,
                on_collect: ->(post_test, component){generic_create_node(post_test, component)}
              }
            )
          )          

        end
        # / POST TEST

        # GENERIC NODE CREATION
        def generic_create_node(node, component)
          node.create(
            namespace: 'staff',
            extra_params: {
              post_id: n_state(:post).id, 
              position:  @current_edited_node_position + 1
            },
            yield_response: true
          ).then do |response|
            begin 
            post_node = parse_post_node_set_node_validate(response.json, node)
            
            if post_node.node.has_errors?
              #postimage has to copy the file in order to rerender it on error
              if node.is_a?(PostImage)
                component.update_when_has_errors
              else
                component.force_update
              end

            else
              modal_close
              insert_created_post_node(post_node)
              
            end
            rescue Exception => e
              `console.log(#{e})`
            end
          end        
        end

        # / GENERIC NODE CREATION

        #INSERT NODE RELATED
        #used when node is created on #then promise resolution in order to
        #preserve pointer to node, so it's the same node as in `new` component 
        def parse_post_node_set_node_validate(json, node)
          post_node = PostNode.parse(json)
          node.attributes = post_node.node.attributes
          post_node.node = node
          post_node.validate
          post_node
        end

        #inserts node to post_nodes on post and performing required cleaning
        def insert_created_post_node(post_node)
          clear_insert_toolbar_before(@current_edited_node_position)
          n_state(:post).post_nodes.data.insert(@current_edited_node_position + 1, post_node)
          @current_edited_node_position = false
          set_state post: n_state(:post)
        end
        #/ INSERT NODE RELATED

        #CHANGING NODE POSITION
        def init_change_index_position(position)
          set_state changing_position: true, element_to_change_position: position
        end

        def paste_at_position(position)
          node  = nodes.data.delete_at(state.element_to_change_position)
          nodes.data.insert(position, node)
          set_state post: state.post, changing_position: false, element_to_change_position: false
        end
        #END CHANGING NODE POSITION

        #used in render when itearating over post_nodes. purpose is to render right show for each specific model
        def view_node(post_node)
          node = post_node.node
          case node
          when PostText
            show_text_node(post_node)
          when PostImage
            show_image_node(node)
          when PostGif
            show_gif_node(node)
          when VideoEmbed
            show_video_embed(node)
          when PostVotePoll
            show_post_vote_poll(node)
          when PostTest
            show_post_test(node)
          when MediaStory
            show_media_story(node)
          end
        end

        #SHOW WRAPPERS FOR NODES
        def show_text_node(post_node)
          node = post_node.node
          if node.id
            t(Components::PostTexts::Edit, {post_text: node, post_node: post_node})
          else
            t(:div, {},
              input(Components::Forms::WysiTextarea, post_text, :content, {record_changes: true})
            )
          end
        end

        def show_image_node(image_node)
          t(:div, {},
            t(Components::PostImages::Show, {post_image: image_node})
          )
        end

        def show_gif_node(post_gif)
          t(:div, {},
            t(Components::PostGifs::Show, {post_gif: post_gif})
          )
        end

        def show_video_embed(video_embed)
          t(Components::VideoEmbeds::Show, {video_embed: video_embed})
        end

        def show_post_vote_poll(post_vote_poll)
          t(Components::VotePolls::Edit, {vote_poll: post_vote_poll})
        end

        def post_vote_poll_edit_done(post_test)
          modal_close
          force_update
        end

        def show_post_test(post_test)
          t(Components::PostTests::Edit, {post_test: post_test})
        end



        def open_for_edit_post_test(post_test)
          modal_open(
            nil,
            t(Components::PostTests::Edit, {post_test: post_test, on_cancel: event(->(_post_test){post_test_edit_done(_post_test)})})
          )
        end

        def post_test_edit_done(post_test)
          modal_close
          force_update
        end

        def show_media_story(media_story)
          t(:div, {},
            t(Components::MediaStories::Show, {media_story: media_story}),
            t(:button, {onClick: ->{open_for_edit_media_story(media_story)}})
          )
        end

        def open_for_edit_media_story(media_story)
          modal_open(
            nil,
            t(Components::MediaStories::Edit, {media_story: media_story})
          )
        end

        #END SHOW WRAPPERS FOR NODES

        
        #TITLE

        def handle_title_change
          post = n_state(:post)
          unless post.attribute_was_changed?(:title)
            post.record_change_for_attribute(:title)
            force_update
          end
        end

        def update_title
          post = n_state(:post)
          collect_inputs(form_model: :post, namespace: 'title')

          post.update_title.then do |returned_post|
            errors = returned_post.errors[:title]
            post.title = returned_post.title
            if errors 
              post.errors[:title] = errors
            else
              post.errors.delete(:title)
            end
            post.clear_change_record_for_attribute(:title)
            force_update
          end
        end

        #/TITLE

        #KARMA

        def handle_karma_change
          karma = n_state(:post).post_karma
          unless karma.attribute_was_changed?(:count)
            karma.record_change_for_attribute(:count)
            force_update
          end
        end

        def change_karma
          collect_inputs(form_model: :post, namespace: 'karma_count', component: self)
          state.post.post_karma.update_count(namespace: 'staff/user_submitted').then do |post_karma|
            if post_karma.has_errors?
              state.post.post_karma.errors = post_karma.errors
              set_state post: state.post
            else
              state.post.post_karma.count = post_karma.count
              state.post.post_karma.clear_change_record_for_attribute(:count)
              force_update
            end
          end
        end

        #/KARMA

        #REMOVE NODE
        def remove_node(i)
          post_node = n_state(:post).post_nodes.data[i]

          post_node.node.destroy(
            namespace: 'staff',
            extra_params: {post_node_id: post_node.id}
          ).then do |node|
            begin
            if node.has_errors? 
              post_node.node.errors = node.errors
            else
              post_node.node.reset_errors
              insert_toolbar_before = n_state(:insert_toolbar_before)
              insert_toolbar_before.delete(i)
              n_state(:post).post_nodes.data.delete_at(i)
            end
            set_state post: state.post, insert_toolbar_before: n_state(:insert_toolbar_before)
            rescue Exception => e
              `console.log(#{e})`
            end
          end   
        end
        #/REMOVE NODE


      end
    end
  end
end
