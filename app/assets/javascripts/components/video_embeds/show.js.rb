module Components
  module VideoEmbeds
    class Show < RW
      expose

      def validate_props
        unless props.video_embed && props.video_embed.is_a?(VideoEmbed)
          puts "#{self.class.name} reuired prop video_embed expected
                got #{props.video_embed} of #{props.video_embed.class.name} "
        end
        #no_playback: Boolean - flags if should playback on click
      end

      def get_initial_state
        youtube_id = get_id(n_prop(:video_embed).link)
        @link_to_thumbnail = "http://img.youtube.com/vi/#{youtube_id}/mqdefault.jpg"
        {
          playbacked: false
        }
      end

      def render
        t(:div, {className: "VideoEmbed-Show"},
          if n_state(:playbacked)
            t(:div, {className: 'video-embed-show embed-responsive embed-responsive-16by9'},
              t(:iframe, {key: props.video_embed.link, src: "#{props.video_embed.link}?autoplay=1", className: 'embed-responsive-item'})
            )
          else
            t(:div, {className: 'img-thumb', onClick: ->{toggle_playbacked}},
              t(:img, {className: 'img-responsive', src: @link_to_thumbnail}),
              unless n_prop(:no_playback)
                t(:i, {className: 'play-btn icon-play'})
              end
            )
          end
        )
      end

      def toggle_playbacked
        unless n_prop(:no_playback)
          set_state(playbacked: !n_state(:playbacked))
        end
      end

      def get_id(link)
        link.split('/')[-1]
      end

    end
  end
end
