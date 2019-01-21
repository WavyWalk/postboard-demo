module Components
  module VideoEmbeds
    class New < RW

      expose

      include Plugins::Formable

      def init
        p 'inited'
      end

      def get_initial_state
        if !props.video_embed.has_errors? && props.video_embed.link
          submitted = true
        else
          submitted = false
        end
        {
          form_model: props.video_embed,
          submitted: submitted
        }
      end

      def render
        t(:div, {className: 'video-embed-new'},
          if state.submitted
            [
            if state.form_model.has_errors?
              t(:div, {className: 'errors'},
                state.form_model.errors.map do |error|
                  t(:p, {}, "#{error}")
                end
              )
            end,
            t(Components::VideoEmbeds::Show, {video_embed: state.form_model}),
            t(:button, { onClick: ->{cancel}, className: 'btn btn-xs' }, 'cancel and insert another')
            ]
          else
            [
            t(:p, {}, 'insert your youtube link here'),
            input(Components::Forms::Input, state.form_model, :link, {record_changes: props.record_changes}),
            t(:button, {onClick: ->{submit}, className: 'btn btn-xs submit-btn' }, 'ok')
            ]
          end
        )
      end

      def submit
        collect_inputs
        state.form_model.link = Services::JsHelpers.translate_youtube_link_to_embed(state.form_model.link)
        if state.form_model.link == 'error'
          state.form_model.add_error('link', 'invalid link provided')
          set_state form_model: state.form_model
          
        else
          if n_prop(:on_collect)
            n_prop(:on_collect).call(n_state(:form_model), self)
            return
          end

          n_state(:form_model).create.then do |video_embed|
            if video_embed.has_errors?
              set_state form_model: video_embed
            else
              set_state(form_model: video_embed, submitted: true)
              emit(:on_done, video_embed) if n_prop(:on_done)
            end
          end
        end
      end

      def cancel
        state.form_model.link = nil
        state.form_model.provider = nil
        set_state form_model: state.form_model, submitted: false
      end

    end
  end
end
