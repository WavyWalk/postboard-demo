module Components
  module Users
    module Avatars
      class Edit < RW
        expose

        include Plugins::Formable

        def validate_props

        end

        def get_initial_state
          {
            image_chosen: false
          }
        end

        def render
          avatar_url = (
            if n_prop(:user).avatar.is_a?(Hash)
              n_prop(:user).avatar[:thumb_url]
            end
          ) 

          t(:div, {className: 'avatars-edit'},
            modal,
            if errors = n_prop(:user).errors[:avatar]
              t(:div, {className: "errors"},
                errors.map do |error|
                  t(:p, {className: 'invalid'},
                    error
                  )
                end
              )
            end,
            if !n_state(:image_chosen)
              if avatar_url
                t(:div, {className: 'image'},
                  t(:img, {src: avatar_url, className: 'image'})
                )
              else
                t(:div, {className: 'absent-avatar'},
                  t(:p, {}, 'you have no avatar')
                )
              end
            end,
            t(Components::PostImages::New,
              {
                acts_as_proxy: true,
                on_image_selected: event(->(file){upload_avatar(file)}),
                hide_alt_text: true,
                on_file_chosen_by_user: ProcEvent.new(->{on_file_chosen_by_user}),
                on_cancel_upload: ProcEvent.new(->{on_cancel_upload}),
                ref: "new_image_component"
              }
            )
          )
        end

        def on_file_chosen_by_user
          set_state(image_chosen: true)
        end

        def on_cancel_upload
          set_state(image_chosen: false)
        end

        def upload_avatar(file)
          n_prop(:user).reset_errors
          n_prop(:user).avatar = file
          n_prop(:user).update_avatar(wilds: {id: n_prop(:user_id)}).then do |user|
            if user.has_errors?
              force_update
            else
              n_prop(:user).attributes.delete(:avatar)
              set_state(image_chosen: false)
            end
          end
        end


      end
    end
  end
end
