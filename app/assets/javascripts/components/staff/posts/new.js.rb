module Components
  module Staff
    module Posts
      class New < RW
        expose

        include Plugins::Formable

        def get_initial_state
          @current_edited_node_position = false
          {
            post: Post.new(post_nodes: ModelCollection.new, post_tags: ModelCollection.new),
            changing_position: false
          }
        end

        def render
          t(:div, {},
            modal,
            general_errors_for(state.post),
            input(Components::Forms::Input, state.post, :title, {show_name: 'title'}),
            controll_toolbar(-1),
            state.post.post_nodes.each_with_index.map do |node, i|
              t(:div, {key: node},
                t(Components::Posts::NodeWrapper, { position: i, on_remove: event(->{remove_node(i)}) },
                  view_node(node)
                ),
                controll_toolbar(i)
              )
            end,
            t(:div, {},
              input(Components::Forms::MultipleSelectAutocompleWithTypeInput, state.post, :post_tags, {show_attribute: 'name', parsing_model: 'PostTag', autocomplete_url: '/post_tags/autocompletes'})
            ),
            t(:button, { onClick: ->{handle_inputs} }, 'create post')
          )
        end

        #removes node at index from nodes; called from ProcEcent passed to children
        def remove_node(index)
          nodes.data.delete_at(index)
          set_state post: state.post
        end

        #toolbar is added after each node, which is used for adding node components in specified order (position)
        def controll_toolbar(position)
          t(:div, {},
            if !nodes[position].is_a?(PostText) && !(position == -1 && nodes[0].is_a?(PostText))
              t(:button, {onClick: ->{put_text_node_at(position)} }, 'add text')
            end,
            t(:button, {onClick: ->{init_image_insertion(position)} }, 'add image'),
            t(:button, {onClick: ->{init_gif_insertion(position)} }, 'add gif'),
            if state.changing_position && position != -1
              t(:button, {onClick: ->{paste_at_position(position)} }, 'paste here')
            else
              unless position == -1
                t(:button, {onClick: ->{init_change_index_position(position)} }, 'cut')
              end
            end
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

        def modal_head_for_image_insert
          t(:p, {}, 'upload image and select it')
        end

        def modal_content_for_image_insert
          t(:div, {},
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image_component(image)}) } )
          )
        end

        def modal_head_for_gif_insert
          t(:p, {}, 'upload gif')
        end

        def modal_content_for_gif_insert
          t(:div, {},
            t(Components::PostGifs::New, {on_post_gif_uploaded: event(->(post_gif){insert_gif_component(post_gif)}) })
          )
        end

        def insert_image_component(post_image)
          nodes.insert(@current_edited_node_position + 1, post_image)
          @current_edited_node_position = false
          set_state post: state.post
          modal_close
        end

        def insert_gif_component(post_gif)
          #deleting file cause gif is yielded from new and file attr contains unserializeble js FormData
          post_gif.attributes.delete(:file)
          nodes.insert(@current_edited_node_position + 1, post_gif)
          @current_edited_node_position = false
          set_state post: state.post
          modal_close
        end
        #END IMAGE NODE INSERTION
        #POST TEXT NODE INSERTION
        def put_text_node_at(position)
          @current_edited_node_position = position
          nodes.insert(position + 1, PostText.new)
          set_state post_image: state.post_image
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
          end
        end

        #SHOW WRAPPERS FOR NODES
        def show_text_node(post_text)
          t(:div, {},
            input(Components::Forms::WysiTextarea, post_text, :content, {})
          )
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
        #END SHOW WRAPPERS FOR NODES

        def handle_inputs

          collect_inputs(form_model: :post)

          if state.post.has_errors?
            set_state post: state.post
          else
            state.post.create(namespace: 'staff').then do |post|
              if post.has_errors?
                set_state post: post
              else
                $HISTORY.pushState(nil, "/posts/#{post.id}")
              end
            end
          end

        end

      end
    end
  end
end
