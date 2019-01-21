module Components
  module Subtitles
    class New < RW
      expose

      def validate_props
        #post_gif : PostGif #required #the gif which subtitles will be added to
        #on_completed : ProcEvent #required #when subtitles persisted on backend successfully,will call for parent
                                            #component to push logic further
      end

      def get_initial_state
        {
          subtitles: [],
          subtitles_to_render: [],
          errors: []
        }
      end

      def render
        t(:div, {className: 'row subtitles-new'},
          t(:div, {className: 'col-lg-6'},
            t(:div, {className: 'video'},
              t(:video, {controls: true, ref: 'vid'},
                t(:source, {src: n_prop(:post_gif).post_gif_url})
              ),
              t(:div, {className: 'subtitle-block'},
                n_state(:subtitles_to_render).map do |subtitle|
                  t(:p, {className: 'individual-subtitle'}, subtitle.content)
                end
              )
            )
          ),
          t(:div, {className: 'col-lg-6 sandbox'},
            t(:button, { onClick: ->{ add_subtitle } }, "add subtitle"),
            t(:button, { onClick: ->{ submit } }, "save subtitles"),
            if (errors = n_state(:errors)).length > 0
              t(:div, {className: 'errors'},
                errors.map do |error|
                  t(:p, {}, error)
                end
              )
            end,
            n_state(:subtitles).map do |subtitle|
              t(Components::Subtitles::CreateIndividual, {
                subtitle: subtitle,
                owner: self,
                on_delete: event(->(_subtitle){delete_subtitle(_subtitle)})
                #on_submit: event(->(_subtitle){add_subtitle(_subtitle)}),
              })
            end
          )
        )
      end

      def add_subtitle
        subtitles = n_state(:subtitles)
        new_sub = Subtitle.create_for_new
        subtitles << new_sub
        set_state subtitles: subtitles
      end

      def delete_subtitle(subtitle)
        subtitles = n_state(:subtitles)
        subtitles.delete(subtitle)
        set_state subtitles: subtitles
      end

      #to be accessed from child via parent prop that caries self
      def get_video_current_time
        @video.JS[:currentTime]
      end

      def component_did_mount
        attach_listeners_to_video
      end

      def attach_listeners_to_video
        @video = n_ref(:vid)
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

      def map_bserach_subtitles(time)
        Subtitle.map_bserach(n_state(:subtitles), time, 0, n_state(:subtitles).length - 1, [], false) do |val|
          %x{
            if (#{time} >= #{val.from} && !(#{time} > #{val.to})) {
              return true
            } else {
              return false
            }
          }
        end
      end

      def submit
        n_prop(:post_gif).add_subtitles(component: self, payload: {post_gif: {id: n_prop(:post_gif).id, subtitles: n_state(:subtitles).to_json}} ).then do |post_gif|
          begin

          post_gif.validate
          if post_gif.has_errors?
            set_state errors: post_gif.errors[:subtitles]
          else
            _post_gif = n_prop(:post_gif)
            _post_gif.subtitles = post_gif.subtitles
            p 'should insert'
            emit(:on_completed, n_prop(:post_gif))
          end
          rescue Exception => e
            p e
          end
        end
      end
      #
      # def component_will_unmount
      #   detach_listeners_to_video
      # end

    end
  end
end
