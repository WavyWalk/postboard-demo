module Components
  module Subtitles
    class CreateIndividual < RW
      expose

      def validate_props
        #subtitle : Subtitle - required
        #owner : Component with #get_video_current_time method
        #on_delete : ProcEvent
      end

      # def get_initial_state
      #
      # end

      def render
        t(:div, {className: 'row subtitle-individual-create'},
          t(:input, {type: 'text', onChange: ->{read_input}, ref: 'input'}),
          t(:button, { className: "btn btn-xs", onClick: ->{set_time_from} }, 'get time'),
          t(:p, {}, "time_from: #{n_prop(:subtitle).from}"),
          t(:button, { className: "btn btn-xs", onClick: ->{set_time_to} }, 'get time'),
          t(:p, {}, "time_to: #{n_prop(:subtitle).to}"),
          t(:button, { onClick: ->{delete} }, "X")
        )
      end

      def read_input
        value = n_ref(:input).JS[:value]
        n_prop(:subtitle).content = value
        force_update
      end

      def set_time_from
        n_prop(:subtitle).from = n_prop(:owner).get_video_current_time
        force_update
      end

      def set_time_to
        n_prop(:subtitle).to = n_prop(:owner).get_video_current_time
        force_update
      end

      def delete
        emit(:on_delete, n_prop(:subtitle))
      end

    end
  end
end
