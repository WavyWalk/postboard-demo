module Components
  module PostGifs
    class New < RW
      expose


      #
      # PROPS
      # accepted props
      #         OPTIONAL
      # on_post_gif_uploaded : ProcEvent event that accepts arg
      # (post_gif : PostGif) - shall be called
      # when gif successfully uploaded to inform parent component.
      # subtitles_allowed : Boolean
      # on_done

      def validate_props
        if x = n_prop(:on_post_gif_uploaded)
          if !x.is_a?(ProcEvent)
            puts "#{self} of #{self.class} - :on_post_gif_uploaded optional prop was
                  passed, that should be of ProcEvent instance, but was not
                  got #{props.on_post_gif_uploaded.class} instead"
          end
        end
      end

      include Plugins::Formable

      def get_initial_state
        {
          post_gif: PostGif.new,
          uploaded: false
        }
      end

      def render
        t(:div, {},
          modal,
          progress_bar,
          unless n_state(:uploaded)
            t(:div, {},
              input(Components::Forms::FileInput, state.post_gif, :file, {show_name: 'choose gif to upload', reset_on_collect: true}),
              t(:button, { onClick: ->{handle_inputs} }, 'upload')
            )
          else
            t(:div, {},
              t(Components::PostGifs::Show, {post_gif: n_state(:post_gif)}),
              t(:div, {},
                t(:button, {onClick: ->{init_subtitle_addition}}, "add subtitles"),
                t(:button, {onClick: ->{emit_on_done}}, "submit")
              )
            )
          end
        )
      end

      def init_subtitle_addition
        modal_open(
          nil,
          t(Components::Subtitles::New, {
            post_gif: n_state(:post_gif),
            on_completed: ->(post_gif){ handle_subtitle_insertion_complete(post_gif) }
          })
        )
      end

      def handle_subtitle_insertion_complete(post_gif)
        set_state(post_gif: post_gif)
        emit_on_done
      end

      def handle_inputs

        collect_inputs(form_model: :post_gif)

        if state.post_gif.has_errors?

          set_state post_gif: state.post_gif

        else

          state.post_gif.create(component: self).then do |_post_gif|
            begin
            if _post_gif.has_errors?
              set_state post_gif: state.post_gif
            else
              perform_action_on_post_gif_upload(_post_gif)
            end
            rescue Exception => e
              p e
            end
          end

        end
      end


      def perform_action_on_post_gif_upload(post_gif)
        if n_prop(:subtitles_allowed)
          set_state uploaded: true
        else
          emit_on_done
        end
      end

      def emit_on_done
        emit(:on_done, n_state(:post_gif))
      end


    end
  end
end
