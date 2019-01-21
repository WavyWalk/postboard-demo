module Components
  module Posts
    module Grids
      class R1c3 < RW
        expose


        def render
          t(:div, {className: 'row R1c3 fl-align-baseline'},
            t(:div, {className: 'col-lg-4 gridPart'},
              children.JS[0],
            ),
            t(:div, {className: 'col-lg-4 gridPart'},
              children.JS[1],
            ),
            t(:div, {className: 'col-lg-4 gridPart'},
              children.JS[2],
            )
          )          
        end

      end
    end
  end
end