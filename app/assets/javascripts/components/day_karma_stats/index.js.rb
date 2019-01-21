module Components
  module DayKarmaStats
    class Index < RW
      expose

      def get_initial_state
        {
          day_karma_stats: ModelCollection.new
        }
      end

      def component_did_mount
        DayKarmaStat.index.then do |day_karma_stats|
          set_state(day_karma_stats: day_karma_stats)
        end
      end

      def render
        t(:div, {className: 'day-karma-stats-index'},
          n_state(:day_karma_stats).data.map do |day_karma_stat|
            t(:div, {className: 'for-day'},
              t(:div, {className: 'header'},
                t(:div, {className: 'count-shower'},
                  t(:span, {className: 'plus'},
                    "+#{day_karma_stat.up_count}"
                  ),
                  ' / ', 
                  t(:span, {className: 'minus'},
                    "-#{day_karma_stat.down_count.abs}"
                  )
                ),
                t(:span, {className: 'date'}, 
                  `(new Date(#{day_karma_stat.created_at})).toLocaleDateString('us-US', {day: 'numeric', month: 'long', year: '2-digit'})`                  
                )
              ),
              t(:div, {className: 'events-for-day'},
                day_karma_stat.day_karma_events.data.map do |day_karma_event|
                  t(:div, {className: 'day-karma-event-show'},
                    t(:div, {className: 'count-shower'},
                      render_count_shower_for_event(day_karma_event)
                    ),
                    t(:div, {className: 'date'}, 
                      `(new Date(#{day_karma_event.created_at})).toLocaleDateString('us-US', {hour: '2-digit', minute: '2-digit'})`
                    ),
                    t(:div, {className: 'event-disclaimer'},
                      DayKarmaEvent::EVENT_TYPES[day_karma_event.event_type]
                    ),
                    t(:div, {className: 'content_disclaimer'},
                      link_to(
                        t(:p, {dangerouslySetInnerHTML: {__html: day_karma_event.source_text}.to_n}),
                        build_link(day_karma_event)
                      )
                    )
                  )
                end
              )
            )
          end
        )        
      end

      def render_count_shower_for_event(day_karma_event)
        only_plus = day_karma_event.down_count == 0 ? true : false
        only_minus = day_karma_event.up_count == 0 ? true : false

        if only_plus
          t(:span, {className: 'plus'},
            "+#{day_karma_event.up_count}"
          )
        elsif only_minus
          t(:span, {className: 'minus'},
            "-#{day_karma_event.down_count.abs}"
          )
        else   
          [ 
            t(:span, {className: 'plus'},
              "+#{day_karma_event.up_count}"
            ),
            ' / ', 
            t(:span, {className: 'minus'},
              "-#{day_karma_event.down_count.abs}"
            )
          ]
        end
      end

      def build_link(day_karma_event)
        case day_karma_event.source_type
        when 'Post'
          "/posts/#{day_karma_event.source_id}"
        when 'DiscussionMessage'
          "/posts/#{day_karma_event.try(:primary_source_id)}?comment=#{day_karma_event.source_id}"
        end
      end

    end
  end
end
