module Components
  module PostTests
    class ThumbShow < RW
      expose

      def validate_props
        #post_test : PostTest required
      end

      def render
        t(:div, {className: 'postTest-thumbShow'},
          t(:p, {}, "postTest here"),
          t(:h3, {}, n_prop(:post_test).title),
          t(Components::PostImages::Show, {post_image: get_thumbnail})
        )
      end

      def get_thumbnail
        if n_prop(:show_serialized_fields)
          return n_prop(:post_test).s_thumbnail
        else
          return n_prop(:post_test).thumbnail
        end
      end

    end
  end
end