#NOT YET USED PLAN TO WRAP POST NODES IN HERE AND APPLY DRAG / DROP FUNCTIONALITY IN HERE
module Components
  module Posts
    class NodeWrapper < RW
      expose
      #PROPS
      #REQUIRED:
      # changed mind (pass as child), no longer :node : PostText | PostImage
      # :position : Integer

      def validate_props
        # unless props.node
        #   puts "#{self} of #{self.class}: required :node prop was not passed got
        #        #{props.node} of #{props.node.class.name} instead"
        # end
        unless props.position
          puts "#{self} of #{self.class}: required :positin of Integer prop was not passed got
               #{props.node} of #{props.node.class.name} instead"
        end
      end

      def render
        t(:div, {className: 'node-wrapper'},
          t(:div, {className: 'node-container'},
            children
          ),
          t(:div, {className: 'node-controll'},
            t(:button, {onClick: ->{emit(:on_remove)}, className: 'btn btn-xs' }, 'remove this')
          )
        )
      end

    end
  end
end
