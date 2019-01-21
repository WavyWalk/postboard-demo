module Components
  module PersonalityTests
    module AnswerVariants
      class New < RW
        expose

        include Plugins::Formable

        def init
          @count = 0 
        end

        def component_did_mount
          n_prop(:owner).comps_to_call_collect_on << self unless n_prop(:save_in_place)
        end

        def component_will_unmount
          n_prop(:owner).comps_to_call_collect_on.delete(self) unless n_prop(:save_in_place)
        end

        def render
          t(:div, {className: 'AnswerVariants-New'},

            modal,
            t(:div, {className: 'answer-group'},
              input(Forms::Input, n_prop(:variant), :text, {show_name: "answer", required_field: true})
            ),

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
                      max: 10 
                    }
                  )
                )
              end
            ),

            t(:div, {className: 'g-btn-group'},
              t(:button, {onClick: ->{emit(:on_delete)}, className: 'btn btn-sm'}, 'delete'),

              #if is child for post_test/edit
              if n_prop(:save_in_place)
                t(:button, {onClick: ->{submit_when_save_in_place}, className: 'btn btn-sm'}, 'save')
              end
            )
          )          
        end

        def init_image_insertion
          modal_open(
            nil,
            t(Components::PostImages::UploadAndPreview, {on_image_selected: event(->(image){insert_image(image)}), post_images: n_prop(:image_roster) } )
          )
        end

        def insert_image(image)
          modal_close
          n_prop(:variant).content = image
          #n_prop(:variant).question_type = "PostImage"
          n_prop(:variant).content_type = 'PostImage'
          force_update
        end

        def delete_image
          n_prop(:variant).content = nil
          n_prop(:variant).content_type = nil
          #n_prop(:variant).question_type = nil
          force_update
        end

        def handle_inputs
          collect_inputs
        end

        def submit_when_save_in_place
          handle_inputs
          n_prop(:variant).personality_test_create.then do |variant|
            begin
            n_prop(:owner).populate_variant_scales_with_personalities(variant)
            n_prop(:owner).force_update
            rescue Exception => e
              p e
            end
          end
        end



      end
    end
  end
end