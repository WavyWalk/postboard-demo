module Components
  module PostTests
    module Gradations
      class Edit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          gradation = n_prop(:gradation)
          {
            gradation: gradation,
            gradation_changed: false
          }
        end

        def render
          t(:div, {},
            modal,
            t(:div, {},
              if n_state(:gradation).errors
                n_state(:gradation).errors.map do |er|
                  t(:p, {}, er)
                end
              end,
              t(:button, {onClick: ->{destroy_gradation}}, 'delete this'),
              input(Forms::Input, n_state(:gradation), :from, {show_name: 'score from', required_field: true, on_change: ->{set_gradation_changed}}),
              input(Forms::Input, n_state(:gradation), :to, {show_name: 'score from', required_field: true, on_change: ->{set_gradation_changed}}),
              input(Forms::Input, n_state(:gradation), :message, {show_name: 'message', on_change: ->{set_gradation_changed}}),
              if n_state(:gradation_changed)
                t(:button, {onClick: ->{update_gradation}}, 'udpate')
              end,

              if n_state(:gradation).content
                t(:div, {},
                  t(Components::PostImages::Show, {post_image: n_state(:gradation).content}),
                  t(:button, {onClick: ->{delete_content_image}}, 'delete'),
                  t(:button, {onClick: ->{init_image_insertion_for_content}}, "replace image")
                )
              else
                t(:button, {onClick: ->{init_image_insertion_for_content}}, "add image")
              end
            )
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
            t(Components::PostImages::UploadAndPreview, 
              {
                on_image_selected: event(->(image){insert_image_to_content(image)}), 
                post_images: n_prop(:image_roster) 
              } 
            )
          )
        end

        def insert_image_to_content(image)
          modal_close
          image.update_post_test_gradation_as_content(
            wilds: {post_test_gradation_id: n_state(:gradation).id, id: image.id}
          ).then do |u_img|
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_state(:gradation).add_error(:content, er)
              end
            else
              n_state(:gradation).content = u_img
              n_state(:gradation).content_type = 'PostImage'
            end
            set_state(gradation: n_state(:gradation))
          end
        end

        def delete_content_image
          n_state(:gradation).content.remove_from_post_test_gradation(
            wilds: {post_test_gradation_id: n_state(:gradation).id}
          ).then do |image|
            if image.has_errors?
              image.errors.each do |er|
                n_state(:gradation).add_error(:content, er)
              end
            else
              n_state(:gradation).content_id = nil
              n_state(:gradation).content = nil
              n_state(:gradation).content_type = nil
            end
            set_state gradation: n_state(:gradation)
          end
        end

        def set_gradation_changed
          unless n_state(:gradation_changed)
            set_state gradation_changed: true
          end
        end

        def update_gradation
          collect_inputs
          n_state(:gradation).update(wilds: {post_test_id: n_prop(:owner).n_state(:post_test).id}).then do |gradation|
            if gradation.has_errors?
              gradation.id = n_state(:gradation).id
              set_state gradation: gradation
            else
              gradation.id = n_state(:gradation).id
              set_state({gradation_changed: false, gradation: gradation})
            end
          end
        end

        def destroy_gradation
          n_state(:gradation).destroy.then do |gradation|
            if gradation.has_errors?
              set_state gradation: gradation
            else
              emit(:on_delete, gradation)
            end
          end
        end

      end
    end
  end
end
