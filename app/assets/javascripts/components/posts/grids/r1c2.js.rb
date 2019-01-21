module Components
  module Posts
    module Grids
      class R1c2 < RW
        expose


        def render
          t(:div, {className: 'row R1c3 fl-align-baseline'},
            t(:div, {className: 'col-lg-6'},
              children.JS[0],
            ),
            t(:div, {className: 'col-lg-6'},
              children.JS[1]
            )
          )          
        end

      end
    end
  end
end