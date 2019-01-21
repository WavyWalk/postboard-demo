module Components
  module PersonalityTests
    module AnswerVariants
      class Edit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            text_changed: false
          }
        end

        def render
          t(:div, {className: 'PersonalityTests AnswerVariants-New Edit'},
            modal,
            t(:div, {className: 'answer-group'},
              input(Forms::Input, n_prop(:variant), :text,
                {
                  show_name: "answer", required: true,
                  on_change: ->{set_text_changed}
                }
              ),
            ),
            if n_state(:text_changed)
              t(:div, {},
                t(:button, {onClick: ->{update_text}}, 'update text')
              )
            end,
            t(:div, {className: 'm_content'},
              if n_prop(:variant).content && n_prop(:variant).content_type == "PostImage"
                t(:div, {className: 'PostTest-Variant-Image'},
                  t(Components::PostImages::Show, {post_image: n_prop(:variant).content}),
                  t(:div, {className: 'g-btn-group'},
                    t(:button, {onClick: ->{delete_image}, className: 'btn btn-sm'}, "remove this")
                  )
                )
              else
                t(:div, {className: 'g-btn-group'},
                  t(:button, {onClick: ->{init_image_insertion}, className: 'btn btn-sm'}, "add image")
                )
              end
            ),

            t(:div, {className: 'personality_scales'},
              n_prop(:variant).personality_scales.map do |personality_scale|
                t(:div, {},
                  t(:p, {}, personality_scale.p_t_personality.title),
                  input(Forms::RangeInput, personality_scale, :scale,
                    {
                      min: 0,
                      max: 10,
                      on_change: ->{set_personality_scale_scale_changed(personality_scale)}
                    }
                  ),
                  if personality_scale.scale_changed
                    t(:div, {},
                      t(:button, {onClick: ->{update_scale(personality_scale)}}, 'update this scale')
                    )
                  end
                )
              end
            ),

            t(:div, {className: 'g-btn-group'},
              unless n_prop(:save_in_place)
                t(:button, {onClick: ->{delete}, className: 'btn btn-sm'}, 'delete')
              end,
              #if is child for post_test/edit
              if n_prop(:save_in_place)
                t(:button, {onClick: ->{submit_when_save_in_place}, className: 'btn btn-sm'}, 'save')
              end
            )
          )
        end

        def set_personality_scale_scale_changed(personality_scale)
          personality_scale.scale_changed = true
          force_update
        end

        def update_scale(personality_scale)
          collect_inputs
          personality_scale.update.then do
            personality_scale.scale_changed = false
            force_update
          end
        end

        def set_text_changed
          set_state(text_changed: true)
        end

        def update_text
          collect_inputs
          n_prop(:variant).update.then do |variant|
            force_update
          end
        end

        def init_image_insertion
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview,
              {
                on_image_selected: event(->(image){insert_image_to_content(image)}),
                post_images: []
              }
            )
          )
        end

        def insert_image_to_content(image)
          modal_close
          image.update_test_answer_variant_as_content(wilds: {test_answer_variant_id: n_prop(:variant).id}).then do |u_img|
            if u_img.has_errors?
              u_img.errors.each do |er|
                n_prop(:variant).add_error(:content, er)
              end
            else
              n_prop(:variant).content = u_img
              n_prop(:variant).content_type = 'PostImage'
              n_prop(:variant).content_id = u_img.id
            end
            force_update
          end
        end

        def delete_image
          n_prop(:variant).content.remove_from_test_answer_variant(
            wilds: {test_answer_variant_id: n_prop(:variant).id}
          ).then do |image|
            if image.has_errors?
              image.errors.each do |er|
                n_prop(:variant).add_error(:content, er)
              end
            else
              n_prop(:variant).content = nil
              n_prop(:variant).content_type = nil
            end
            set_state variant: n_prop(:variant)
          end
        end

        def delete
          if n_prop(:variant).id
            n_prop(:variant).personality_test_destroy.then do |variant|
              begin
              if variant.has_errors?
                force_update
              else
                emit(:on_delete, variant)
              end
              rescue Exception => e
                p e
              end
            end
          else
            emit(:on_delete, variant)
          end
        end

      end
    end
  end
end
