module Components
  module PostTests
    module AnswerVariants
      class Edit < RW

        expose

        include Plugins::Formable

        def get_initial_state
          variant = n_prop(:variant)
          {
            variant: variant,
            variant_changed: false
          }
        end

        def render
          t(:div, {},
            modal,
            if x = n_state(:variant).errors[:general]
              x.map do |er|
                t(:p, {}, er)
              end
            end,
            if n_state(:variant_changed)
              t(:button, {onClick: ->{update_variant}}, 'update')
            end,
            if n_state(:variant).correct
              t(:button, {onClick: ->{toggle_correct}}, 'mark as incorrect answer')
            else
              t(:button, {onClick: ->{toggle_correct}}, 'mark as correct answer')
            end,
            input(Forms::Input, n_state(:variant), :text, {show_name: "answer", on_change: event(->{set_variant_changed})}),
            if n_state(:variant).content && n_state(:variant).content_type == "PostImage"
              t(:div, {className: 'PostTest-Variant-Image'},
                t(Components::PostImages::Show, {post_image: n_state(:variant).content}),
                t(:button, {onClick: ->{delete_image}}, "remove this"),
                t(:button, {onClick: ->{init_image_insertion}}, "replace this")
              )
            else
              t(:button, {onClick: ->{init_image_insertion}}, "add image")
            end,
            t(:button, {onClick: ->{destroy_variant}}, 'delete')
          )
        end

        def toggle_correct
          n_state(:variant).correct = !n_state(:variant).correct
          set_state({variant: n_state(:variant), variant_changed: true})
        end

        def init_image_insertion
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview, 
              {
                on_image_selected: event(->(image){insert_image_to_content(image)
              }
            ), post_images: n_prop(:image_roster) } )
          )

        end

        def insert_image_to_content(image)
          modal_close
          image.update_test_answer_variant_as_content(wilds: {test_answer_variant_id: n_state(:variant).id}).then do |u_img|
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_state(:variant).add_error(:content, er)
              end
            else
              n_state(:variant).content = u_img
              n_state(:variant).content_type = 'PostImage'
            end
            set_state(variant: n_state(:variant))
          end
        end


        def delete_image
          n_state(:variant).content.remove_from_test_answer_variant(wilds: {test_answer_variant_id: n_state(:variant).id}).then do |image|
            if image.has_errors?
              image.errors.each do |er|
                n_state(:variant).add_error(:content, er)
              end
            else
              n_state(:variant).content = nil
              n_state(:variant).content_type = nil
            end
            set_state variant: n_state(:variant)
          end
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self)
        end

        def handle_inputs
          collect_inputs(form_model: :variant)
        end

        def set_variant_changed
          unless n_state(:variant_changed)
            set_state variant_changed: true
          end
        end

        def update_variant
          collect_inputs
          n_state(:variant).update.then do |variant|
            if variant.has_errors?
              #check, should not update children
              set_state({variant: variant})
            else
              set_state({variant_changed: false, variant: variant})
            end
          end
        end

        def destroy_variant
          n_state(:variant).destroy.then do |variant|
            variant.validate
            if variant.has_errors?
              set_state variant: variant
            else
              p 'should del var'
              emit(:on_delete)
            end
          end
        end

      end
    end
  end
end
