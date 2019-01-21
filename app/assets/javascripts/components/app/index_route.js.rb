module Components
  module App
    class IndexRoute < RW
      expose

      def render
        t(:div, {className: 'row'},
          t(:div, {className: 'col-lg-12'},
            t(Components::Posts::Index, {params: props.params, location: props.location, history: props.history})
          ),
          # t(:div, {className: 'col-lg-4'},
          #   t(Components::App::Sidebar, {})
          # )
        )
      end

    end
  end
end
