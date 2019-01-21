module Components
  module PostTests
    module Gradations
      class NewForEdit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          @comps_to_call_collect_on
          gradation = n_prop(:gradation)
          {
            gradation: gradation
          }
        end

        def render
          t(:div, {},
            modal,
            t(:div, {},
              input(Forms::Input, n_state(:gradation), :from, {show_name: 'score from', required_field: true}),
              input(Forms::Input, n_state(:gradation), :to, {show_name: 'score from', required_field: true}),
              input(Forms::Input, n_state(:gradation), :message, {show_name: 'message'}),

              if n_state(:gradation).content
                t(:div, {},
                  t(Components::PostImages::Show, {post_image: n_state(:gradation).content}),
                  t(:button, {onClick: ->{delete_content_image}}, 'delete')
                )
              else
                t(:button, {onClick: ->{init_image_insertion_for_content}}, "add image")
              end
            ),
            if n_prop(:save_in_place)
              t(:button, {onClick: ->{submit_when_save_in_place}}, 'save')
            end
          )
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:save_in_place)
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:save_in_place)
        end

        def handle_inputs
          collect_inputs
        end

        def set_content_nil(gradation)
          gradation.content = nil
          force_update
        end

        def init_image_insertion_for_content
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image(image)}), post_images: n_prop(:image_roster) } )
          )
        end

        def insert_image(image)
          modal_close
          n_state(:gradation).content = image
          n_state(:gradation).content_type = 'PostImage'
          force_update
        end

        def submit_when_save_in_place
          collect_inputs
          n_state(:gradation).create(wilds: {post_test_id: n_prop(:owner).n_state(:post_test).id}).then do |gradation|
            if gradation.has_errors?
              set_state gradation: gradation
            else
              emit(:on_done, gradation)
            end
          end
        end

      end
    end
  end
end
