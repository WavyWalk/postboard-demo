module Components
  module PostTests
    module Gradations
      class New < RW
        expose

        include Plugins::Formable

        def get_initial_state
          @comps_to_call_collect_on
          {}
        end

        def render
          t(:div, {},
            modal,
            n_prop(:gradations).data.map do |gradation|
              t(:div, {},
                input(Forms::Input, gradation, :from, {show_name: 'score from', required_field: true}),
                input(Forms::Input, gradation, :to, {show_name: 'score from', required_field: true}),
                input(Forms::Input, gradation, :message, {show_name: 'message'}),
                if gradation.content
                  t(:div, {},
                    t(Components::PostImages::Show, {post_image: gradation.content}),
                    t(:button, {onClick: ->{set_content_nil(gradation)}}, 'delete')
                  )
                else
                  t(:button, {onClick: ->{init_image_insertion_for(gradation)}}, "add image")
                end
              )
            end,
            t(:button, {onClick: ->{add_gradation}}, "add gradation")
          )
        end

        def add_gradation
          n_prop(:gradations).data << PostTestGradation.new
          force_update
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self)
        end

        def handle_inputs
          collect_inputs
        end

        def set_content_nil(gradation)
          gradation.content = nil
          force_update
        end

        def init_image_insertion_for(gradation)
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image(gradation, image)}), post_images: n_prop(:image_roster) } )
          )
        end

        def insert_image(gradation, image)
          modal_close
          gradation.content = image
          gradation.content_type = 'PostImage'
          force_update
        end

      end
    end
  end
end
