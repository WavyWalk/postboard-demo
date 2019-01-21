module Components
  module PostKarmaTransactions
    class New < RW

      expose

      include Plugins::Formable
      #PROPS
      #REQUIRED
      #post_karma_id : Integer
      #OPTIONAL:
      #post : Post; for case posts index will yield the post_karma-transaction and post
      def validate_props
        if !n_prop(:pkt) || !n_prop(:pkt).is_a?(PostKarmaTransaction)
          p "WARNING: #{self.cklass.name} expects pkt prop of PostKarmaTransaction type, got #{n_prop(:pkt)} instead"
        end
      end



      def get_initial_state
        {

        }       
      end


      def liked? 
        (n_prop(:pkt).amount || 0) > 0 ? "liked" : nil
      end

      def disliked?
        (n_prop(:pkt).amount || 0) < 0 ? "disliked" : nil
      end

      def component_will_receive_props(np)
        # p 'pkt-new receveing props'
        # if np.post_karma_id != props.post_karma_id
        #   props.post_karma_id = np.post_karma_id
        #   set_state get_initial_state
        # end
      end


      def render
        t(:div, {className: 'like-group zoom'},
          t(:span, { onClick: ->{ like }, className: liked? },
            t(:i, {className: 'icon-thumbs-up-1'})
          ),
          t(:span, {onClick: ->{ dislike }, className: disliked? },
            t(:i, {className: 'icon-thumbs-down-1'})
          )
          # t(:button, { onClick: ->{ like10 } }, 'like 10'),
          # t(:button, { onClick: ->{ likeminus10 } }, 'like -10')
        )
      end

      #TODO the value on which to update shall be given from backend
      def like
        n_prop(:pkt).previous_amount = n_prop(:pkt).amount || 0
        n_prop(:pkt).amount = 1
        create
      end

      def dislike
        n_prop(:pkt).previous_amount = n_prop(:pkt).amount || 0
        n_prop(:pkt).amount = -1
        create
      end

      # def like10
      #   state.post_karma_transaction.amount = 10
      #   create
      # end

      # def likeminus10
      #   state.post_karma_transaction.amount = -10
      #   create
      # end

      def create
        pkt = n_prop(:pkt)
        pkt.create.then do |post_karma_transaction|

          begin

          if post_karma_transaction.has_errors?
            if post_karma_transaction.errors[:general]
              alert post_karma_transaction.errors[:general]
            else
              set_state post_karma_transaction: post_karma_transaction
            end
          else


            CurrentUser.update_karma(post_karma_transaction.attributes[:user_change_amount])

            pkt.attributes = post_karma_transaction.attributes
            if n_prop(:post_karma)
              n_prop(:post_karma).count += post_karma_transaction.amount_change_factor
            end
            # if props.post
            #   emit_args = [:on_post_karma_transaction_created, post_karma_transaction, props.post]
            # else
            #   emit_args = [:on_post_karma_transaction_created, post_karma_transaction]
            # end

            emit(:pkt_changed, post_karma_transaction) 
            
            force_update
          end

        rescue Exception => e
          p e
        end

        end
      end


    end
  end
end
