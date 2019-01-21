module Components
  module Posts
    class New < RW
      expose

      include Plugins::Formable

      def get_initial_state
        @current_edited_node_position = false
        @current_edited_node_position_for_thumb = false
        {
          post: Post.new(post_nodes: ModelCollection.new, post_tags: ModelCollection.new, post_thumbs: ModelCollection.new),
          changing_position: false,
          post_thumb_expanded: false,
          changing_position_for_thumb: false,
          post_images_in_roster: ModelCollection.new,
          insert_toolbar_before: {}
        }
      end

      def render
        if CurrentUser.instance.has_role?('guest')
          t(Components::Users::Create, 
            {
              message: 'you should provide username in order to create post', 
              on_signup: event(->{after_signup_ok})
            }
          )
        else
          t(:div, {className: 'posts-new'},
            modal,
            general_errors_for(state.post),
            t(:div, {className: 'row title-input'},
              input(Components::Forms::Input, state.post, :title, {show_name: 'title', required_field: true})
            ),
            # if state.post_thumb_expanded
            #   t(:div, {className: 'post-thumb'},
            #     post_thumbs_controll_toolbar(-1),
            #     state.post.post_thumbs.each_with_index.map do |post_thumb, i|
            #       t(:div, {key: i},
            #         t(Components::Posts::NodeWrapper, { position: i , on_remove: event(->{ remove_post_thumb_node(i) }) },
            #           view_node(post_thumb.node)
            #         ),
            #         if post_thumbs.data.length < 2
            #           post_thumbs_controll_toolbar(i)
            #         end
            #       )
            #     end,
            #     t(:button, { onClick: ->{toggle_thumbnail_expanded} }, 'cancel')
            #   )
            # else
            #   t(:button, { onClick: ->{toggle_thumbnail_expanded} }, 'add thumbnail')
            # end,


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
                      view_node(post_node.node)
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
            ),
            t(:button, { onClick: ->{handle_inputs}, className: 'btn btn-primary' }, 'create post')
          )
        end
      end


      #THUMBNAIL RELATED

      def toggle_thumbnail_expanded
        if state.post_thumb_expanded
          state.post.post_thumbs.data = []
          @current_edited_node_position_for_thumb = false
        end
        set_state post_thumb_expanded: !state.post_thumb_expanded
      end

      #shorthand accessor
      def post_thumbs
        state.post.post_thumbs
      end


      def post_thumbs_controll_toolbar(position)
        t(:div, {className: "row controll-toolbar"},
          if !(post_thumbs[position].try(:node_type) == 'PostText') && !(position == -1 && post_thumbs[position].try(:node_type) == "PostText")
            t(:button, {onClick: ->{put_text_node_thumb_at(position)}, className: 'btn btn-sm btn-default' }, 'add text')
          end,
          t(:button, {onClick: ->{init_image_insertion_for_thumb(position)}, className: 'btn btn-sm btn-default' }, 'add image'),
          #t(:button, {onClick: ->{init_gif_insertion_for_thumb(position)} }, 'add gif'),
          #t(:button, { onClick: ->{ init_video_embed_for_thumb(position) } }, 'embed video'),
          if state.changing_position_for_thumb && position != -1
            t(:button, {onClick: ->{paste_at_position_for_thumb(position)}, className: 'btn btn-sm btn-default' }, 'paste here')
          else
            unless position == -1
              t(:button, {onClick: ->{init_change_index_position_for_thumb(position)}, className: 'btn btn-sm btn-default' }, 'cut')
            end
          end
        )
      end

      def init_change_index_position_for_thumb(position)
        set_state changing_position_for_thumb: true, element_to_change_position_for_thumb: position
      end

      def paste_at_position_for_thumb(position)
        node  = post_thumbs.data.delete_at(state.element_to_change_position_for_thumb)
        post_thumbs.data.insert(position, node)
        set_state post: state.post, changing_position_for_thumb: false, element_to_change_position_for_thumb: false
      end

      def remove_post_thumb_node(index)
        post_thumbs.data.delete_at(index)
        set_state post: state.post
      end

      def put_text_node_thumb_at(position)
        return if validate_addition_post_thumb_addition_failed?
        @current_edited_node_position_for_thumb = position
        post_thumbs.insert(position + 1, PostNode.new(node: PostText.new, node_type: 'PostText'))
        set_state post: state.post
      end

      def validate_addition_post_thumb_addition_failed?
        if post_thumbs.data.length == 2
          alert 'maximum two elements can be added for thumb'
          return true
        end
      end

      def init_image_insertion_for_thumb(position)
        return if validate_addition_post_thumb_addition_failed?
        @current_edited_node_position_for_thumb = position

        modal_open(
          modal_head_for_image_insert_for_thumb,
          modal_content_for_image_insert_for_thumb
        )
      end

      def modal_head_for_image_insert_for_thumb
        t(:p, {}, 'upload image and select it')
      end

      def modal_content_for_image_insert_for_thumb
        t(:div, {},
          t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image_component_for_thumb(image)}), post_images: n_state(:post_images_in_roster) } )
        )
      end

      def insert_image_component_for_thumb(post_image)

        post_node = PostNode.new(node: post_image, node_type: 'PostImage')

        post_thumbs.insert(@current_edited_node_position_for_thumb + 1, post_node)
        @current_edited_node_position_for_thumb = false
        set_state post: state.post
        modal_close

      end


      #END THUMBNAIL RELATED
      def set_insert_toolbar_before(index)
        set_state insert_toolbar_before: {index => true}
      end

      def clear_insert_toolbar_before(index)
        insert_toolbar_before = {}
        set_state insert_toolbar_before: insert_toolbar_before
      end


      #removes node at index from nodes; called from ProcEvent passed to children
      def remove_node(index)
        nodes.data.delete_at(index)
        insert_toolbar_before = n_state(:insert_toolbar_before)
        insert_toolbar_before.delete(index)
        set_state post: state.post, insert_toolbar_before: insert_toolbar_before
      end

      #toolbar is added after each node, which is used for adding node components in specified order (position)
      def controll_toolbar(position)
        #return nil if n_state(:post).post_nodes.data.length < 1
        t(:div, {className: 'controll-toolbar'},
          if !(nodes[position].try(:node_type) == 'PostText') && !(position == -1 && nodes[position].try(:node_type) == "PostText")
            t(:button, {onClick: ->{put_text_node_at(position)}, className: 'btn btn-sm btn-default' }, 'add text')
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
      #IMAGE NODE INSERTION
      def init_image_insertion(position)

        @current_edited_node_position = position

        modal_open(
          modal_head_for_image_insert,
          modal_content_for_image_insert
        )

      end

      def init_gif_insertion(position)
        @current_edited_node_position = position

        modal_open( modal_head_for_gif_insert, modal_content_for_gif_insert )
      end


      def init_video_embed(position)
        clear_insert_toolbar_before(@current_edited_node_position)
        @current_edited_node_position = position
        post_node = PostNode.new(node: VideoEmbed.new, node_type: 'VideoEmbed')
        nodes.insert(position + 1, post_node)
        set_state post: state.post

      end

      def init_vote_poll_insertion(position)
        @current_edited_node_position = position
        modal_open(nil,
          t(Components::VotePolls::New, {
              on_done: event(->(vote_poll){insert_vote_poll(vote_poll)}),
              on_cancel: event(->{modal_close})
            }
          )
        )
      end

      def init_post_test_insertion(position)
        @current_edited_node_position = position
        modal_open(nil,
          t(Components::PostTests::New, {
              on_done: event(->(post_test){insert_post_test(post_test)}),
              on_cancel: event(->{modal_close})
            }
          )
        )
      end

      def init_personality_test_insertion(position)
        @current_edited_node_position = position
        modal_open(
          nil,
          t(Components::PersonalityTests::New,
            {
              on_done: event(->(personality_test){insert_personality_test(personality_test)}),
              on_cancel: event(->{modal_close})
            }
          )
        )
      end

      def init_media_story_insertion(position)
        @current_edited_node_position = position
        modal_open(nil,
          t(Components::MediaStories::New,
            {
              on_done: event(->(media_story){insert_media_story(media_story)}),
              on_cancel: event(->{modal_close})
            },
          )
        )
      end

      def modal_head_for_image_insert
        t(:p, {}, 'upload image and select it')
      end

      def modal_content_for_image_insert
        t(:div, {},
          t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image_component(image)}), post_images: n_state(:post_images_in_roster) } )
        )
      end

      def modal_head_for_gif_insert
        t(:p, {}, 'upload gif')
      end

      def modal_content_for_gif_insert
        t(:div, {},
          t(Components::PostGifs::New,
            {
              on_done: event(->(post_gif){insert_gif_component(post_gif)}),
              subtitles_allowed: true
            }
          )
        )
      end

      def insert_image_component(post_image)
        clear_insert_toolbar_before(@current_edited_node_position)
        post_node = PostNode.new(node: post_image, node_type: 'PostImage')
        nodes.insert(@current_edited_node_position + 1, post_node)
        @current_edited_node_position = false
        set_state post: state.post
        modal_close
      end

      def insert_vote_poll(vote_poll)
        clear_insert_toolbar_before(@current_edited_node_position)
        post_node = PostNode.new(node: vote_poll, node_type: "PostVotePoll")
        nodes.insert(@current_edited_node_position + 1, post_node)
        @current_edited_node_position = false
        set_state post: n_state(:post)
        modal_close
      end

      def insert_post_test(post_test)
        p "should insert test #{post_test}"
        clear_insert_toolbar_before(@current_edited_node_position)
        post_node = PostNode.new(node: post_test, node_type: "PostTest")
        nodes.insert(@current_edited_node_position + 1, post_node)
        @current_edited_node_position = false
        set_state post: n_state(:post)
        modal_close
      end

      def insert_personality_test(personality_test)
        p "inserting #{personality_test.attributes}"
        clear_insert_toolbar_before(@current_edited_node_position)
        insert_post_test(personality_test)
      end

      def insert_media_story(media_story)
        p 'should insert media_story'
        clear_insert_toolbar_before(@current_edited_node_position)
        post_node = PostNode.new(node: media_story, node_type: "MediaStory")
        nodes.insert(@current_edited_node_position + 1, post_node)
        @current_edited_node_position = false
        set_state post: n_state(:post)
        modal_close
      end

      # def open_modal_for_post_gif_to_edit_its_subtitles(post_gif)
      #   modal_close
      #   modal_open(
      #     nil,
      #     t(:div, {},
      #       t(:p, {}, "Your gif has been uploaded."),
      #       t(:p, {}, "want to add subtitles, or funny stuff to gif?"),
      #       t(:button, { onClick: ->{open_modal_for_subtitle_insertion_for_gif(post_gif)} }, "yeah!"),
      #       t(:button, { onClck: ->{ insert_gif_component(post_gif) } }, "nope")
      #     )
      #   )
      # end

      # def open_modal_for_subtitle_insertion_for_gif(post_gif)
      #   modal_close
      #   modal_open(
      #     nil,
      #     t(Components::Subtitles::New, {
      #       post_gif: post_gif,
      #       on_completed: ->(post_gif){insert_gif_component(post_gif)}
      #     })
      #   )
      # end

      def insert_gif_component(post_gif)
        #deleting file cause gif is yielded from new and file attr contains unserializeble js FormData
        clear_insert_toolbar_before(@current_edited_node_position)
        post_gif.attributes.delete(:file)
        post_node = PostNode.new(node: post_gif, node_type: 'PostGif')

        nodes.insert(@current_edited_node_position + 1, post_node)
        @current_edited_node_position = false
        set_state post: state.post
        modal_close
      end
      #END IMAGE NODE INSERTION
      #POST TEXT NODE INSERTION
      def put_text_node_at(position)
        clear_insert_toolbar_before(@current_edited_node_position)
        @current_edited_node_position = position
        nodes.insert(position + 1, PostNode.new(node: PostText.new, node_type: 'PostText'))
        set_state post: state.post
      end
      #END POST TEXT NODE INSERTION
      #shortcut accessor
      def nodes
        state.post.post_nodes
      end
      #used in render when itearating over post_nodes. purpose is to render right show for each specific model
      def view_node(node)
        case node
        when PostText
          show_text_node(node)
        when PostImage
          show_image_node(node)
        when PostGif
          show_gif_node(node)
        when VideoEmbed
          show_video_embed_node(node)
        when PostVotePoll
          show_vote_poll_node(node)
        when PostTest
          if node.is_personality
            show_personality_test_node(node)
          else
            show_post_test_node(node)
          end
        when MediaStory
          show_media_story_node(node)
        end
      end

      #SHOW WRAPPERS FOR NODES
      def show_text_node(post_text)
        t(:div, {},
          input(Components::Forms::WysiTextarea, post_text, :content, {focus_on_load: true})
        )
      end

      def show_image_node(image_node)
        t(:div, {},
          t(Components::PostImages::Show, {post_image: image_node})
        )
      end

      def show_gif_node(post_gif)
        t(:div, {},
          t(Components::PostGifs::Show, {post_gif: post_gif, subtitle_addable: true})
        )
      end

      def show_video_embed_node(video_embed)
        t(:div, {},
          t(Components::VideoEmbeds::New, {video_embed: video_embed})
        )
      end

      def show_vote_poll_node(node)
        t(:div, {},
          t(Components::VotePolls::Show, {vote_poll: node}),
          t(:button, { onClick: ->{open_vote_poll_edit(node)} }, "edit")
        )
      end

      def show_post_test_node(node)
        t(:div, {},
          t(Components::PostTests::Show, {post_test: node}),
          #t(:button, { onClick: ->{open_post_test_edit(node)} }, "edit")
        )
      end

      def show_personality_test_node(node)
        t(:div, {},
          t(Components::PersonalityTests::Show,
            {
              post_test: node
            }
          )
        )
      end

      def show_media_story_node(node)
        t(:div, {},
          t(Components::MediaStories::Show,
            {
              media_story: node
            }
          ),
          t(:button, { onClick: ->{open_media_story_edit(node)} }, "edit")
        )
      end

      def open_vote_poll_edit(node)
        modal_open(nil,
          t(Components::VotePolls::New, {
              vote_poll: node,
              on_done: event(->(vote_poll){ modal_close; set_state post: n_state(:post) }),
              on_cancel: event(->{modal_close})
            }
          )
        )
      end

      def open_post_test_edit(node)
        modal_open(nil,
          t(Components::PostTests::Edit, {
              post_test: node,
              on_done: event(->(post_test){ modal_close; set_state post: n_state(:post) }),
              on_cancel: event(->{modal_close; set_state post: n_state(:post)})
            }
          )
        )
      end

      def open_media_story_edit(node)
        modal_open(
          nil,
          t(Components::MediaStories::Edit,
            {
              media_story: node
            }
          )
        )
      end
      #END SHOW WRAPPERS FOR NODES

      def handle_inputs
        collect_inputs(form_model: :post)

        if state.post.has_errors?
          set_state post: state.post
        else
          state.post.create.then do |post|
            if post.has_errors?
              set_state post: post
            else
              $HISTORY.pushState(nil, "/posts/#{post.id}")
            end
          end
        end
      end

      def after_signup_ok
        CurrentUser.ping_current_user.then do |user|
          CurrentUser.set_user_and_login_status(user, true)
        end
      end

    end
  end
end
