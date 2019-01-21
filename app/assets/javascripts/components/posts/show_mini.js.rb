module Components
  module Posts
    class ShowMini < RW
      expose

      def validate_props
        if !props.post || !props.post.is_a?(Post)
          p "#{self.class.name} requires props.post of type Post, got #{props.post} instead"
        end 
      end

      def get_initial_state
        post_nodes = []
        if props.post.post_nodes[0].node.is_a?(PostText)
          props.post.post_nodes[0].node.content = props.post.post_nodes[0].node.content[0..140]
        end

        props.post.post_nodes.each_with_index do |post_node, i|
          break if i >= 1 
          post_nodes << post_node 
        end
        {
          post_nodes: post_nodes
        }

      end

      def render
        t(:div, {className: 'posts-showMini'},
          t(:p, {className: 'title'},
            props.post.title
          ),
          state.post_nodes.map do |post_node|
            t(:div, {className: 'node'},
              show_node_depending_on_type(post_node.node)
            )
          end
        )
      end

      def show_node_depending_on_type(node)
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

    end
  end
end