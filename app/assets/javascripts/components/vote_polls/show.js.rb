module Components
  module VotePolls
    class Show < RW
      expose

      def validate_props
        #vote_poll : PostVotePoll #required
        #show_inline : Bool #optional
      end



      def render
        inline = n_prop(:show_inline) ? 'inline' : ''
        max_count = n_prop(:vote_poll).get_max_count_option

        t(:div, {className: 'PostVotePolls-Show'},
          t(:div, {className: 'question-group'},
            if n_prop(:vote_poll).m_content
              t(:div, {className: 'm_content'},
                t(Components::PostImages::Show, {post_image: n_prop(:vote_poll).m_content, css_class: inline})
              )
            end,
            t(:h3, {className: 'question'}, n_prop(:vote_poll).question)
          ),
          t(:div, {className: 'options'}, 
            n_prop(:vote_poll).vote_poll_options.data.map do |option|
              t(:div, {className: 'option-wrap'},
                t(:div, {className: 'title-group'}, 
                  t(:p, {}, option.content),
                  if option.m_content
                    t(:div, {className: 'option-m_content'},
                      t(Components::PostImages::Show, {post_image: option.m_content, css_class: inline})
                    )
                  end
                ),
                t(:div, {className: 'option'},
                  unless n_prop(:vote_poll).arbitrary['already_voted']
                    t(:div, {className: 'select'},
                      t(:i, {className: 'icon-up-big', onClick: ->{increment(option)}})
                    )
                  end,
                  t(:div, {className: 'proportion', style: {width: "#{calculate_width_proportion(max_count, option.count)}%"}.to_n}),
                  t(:div, {},
                    t(:p, {}, option.count)
                  )
                )
              )
            end
          )
        )
      end

      def calculate_width_proportion(max_count, option_count)
        return 0 if max_count == nil

        if max_count == option_count
          return 100
        elsif max_count > 0
          return ((100/max_count)*option_count).ceil
        else
          return 0
        end
      end

      def increment(option)
        vpt = VotePollTransaction.new(vote_poll_option_id: option.id)
        vpt.create.then do |_vpt|
          if _vpt.has_errors?
            if _vpt.errors[:general].include?(:voted_already)
              alert('you have already voted')
              n_prop(:vote_poll).arbitrary['already_voted'] = true
            end
          else
            option.count += 1
            n_prop(:vote_poll).arbitrary['already_voted'] = true
          end
          force_update
        end
        
      end

      def component_did_mount
        unless n_prop(:vote_poll).loaded
          n_prop(:vote_poll).load_counts.then do |post_vote_poll|
            begin
            force_update
            rescue Exception => e
              `console.log(#{e})`
            end
          end
        end
      end

    end
  end
end