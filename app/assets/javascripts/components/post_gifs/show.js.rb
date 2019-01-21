module Components
  module PostGifs
    class Show < RW
      expose

       #PROPS
      #REQUIRED:
      # :post_gif : PostGif < Model
      #OPTIONAL


      def validate_props
        if !props.post_gif || !props.post_gif.is_a?(PostGif)
          puts "#{self} of #{self.class}: required_prop :post_gif : PostGif was not passed -> got #{props.post_gif} of #{props.post_gif.class} instead"
        end
      end

      def get_initial_state
        if n_prop(:post_gif).dimensions
          width, height = n_prop(:post_gif).dimensions.split('x')
        else
          width, height = [nil, nil]
        end
        if n_prop(:post_gif).subtitles && n_prop(:post_gif).subtitles.length > 0
          @has_subtitles = true
        end
        {
          width: width,
          height: height,
          subtitles_to_render: []
        }
      end

      def render
        t(:div, {className: 'post-gif-show'},
        t(:div, {className: 'video embed-responsive', style: `{width: #{state.width}, height: #{state.height}}`},
            t(:video, {controls: true, loop: true, ref: 'video'},
              t(:source, {src: n_prop(:post_gif).post_gif_url})
            ),
            t(:div, {className: 'subtitle-block'},
              n_state(:subtitles_to_render).map do |subtitle|
                t(:p, {className: 'individual-subtitle'}, subtitle.content)
              end
            )
          )
        )
      end

      def component_did_mount
        if @has_subtitles
          @video = n_ref(:video)
          @subtitles = n_prop(:post_gif).subtitles
          @subtitles_length = @subtitles.length - 1
          attach_listeners_to_video
        end
      end

      def attach_listeners_to_video
        %x{

          #{@video}.ontimeupdate = function(){
            #{find_and_render_subtitles}
          }

        }
      end


      def find_and_render_subtitles

        subtitles = map_bserach_subtitles(get_video_current_time)
        if n_state(:subtitles_to_render) != subtitles
          set_state(subtitles_to_render: subtitles)
        end

      end


      def get_video_current_time
        @video.JS[:currentTime]
      end


      def map_bserach_subtitles(time)
        Subtitle.map_bserach(@subtitles, time, 0, @subtitles_length, [], false) do |val|
          %x{
            if (#{time} >= #{val.from} && !(#{time} > #{val.to})) {
              return true
            } else {
              return false
            }
          }
        end
      end


    end
  end
end
