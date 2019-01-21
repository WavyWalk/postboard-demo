module Components
  module Shared
  	class Modal < RW

      expose

      @@opened_count = 0

      include Plugins::UpdateOnSetStateOnly

      def get_initial_state
        {
          display: "none",
          z_index_value: Services::ModalManager.instance.active_modals_counter
        }
      end

      def init
        @head = t(:p, {})
        @body = t(:div, {}, "foo")
      end

  		def render
  			t(:div, {className: "modal", style: `{display: #{state.display}}`},
  				t(:div, {className: "modal-dialog #{$DISPLAY_SIZE} #{props.className}", role: "document"},
  					t(:div, {className: "modal-content", ref: 'drag_wrap'},
  						t(:div, {className: "modal-header"},
                #t(:button, {draggable: true, onDragStart: ->{set_drag_offsets}, onDragEnd: ->(e){drag_stop(e)}}, 'drag'),
                t(:div, 
                  {
                    style: `{zIndex: #{n_state(:z_index_value)}}`,
                    className: "close", 
                    onClick: ->(){close}                    
                  }, 
                  "X"
                ),
                @head
              ),
              t(:div, {className: "modal-body"},
                @body,
                children
              )
  					)
  				)
  			)
  		end

  		def open(head_content = false, content = false, on_close = false)
        if on_close
          @on_close = on_close
        end
        @@opened_count += 1 unless @opened
        @opened = true
        @head = head_content if head_content
        @body = content if content
  			Element.find("body").add_class("modal-open") if (@@opened_count > 0)
  			set_state display: "block", z_index_value: Services::ModalManager.instance.increment_active_modals_counter
  		end

      # def set_drag_offsets
      #   @dragged_elem = refs[:drag_wrap]
      #   @dragged_elem.style.postition = 'absolute'
      #   @dragged_elem_Y = @dragged_elem.offsetTop
      #   @dragged_elem_X = @dragged_elem.offsetLeft
      #   `$(window).on('mousemove.drag', #{->(e){drag(e)}})`
      # end





      # def drag_stop(e)
      #   `$(window).off('mousemove.drag')`
      # end





      def close(preserve = false, from_unmount = false)
        @@opened_count -= 1 if @opened
        @opened = false
        emit(:on_close) if n_prop(:on_close)
        if n_prop(:on_user_intentional_close)
          emit(:on_user_intentional_close) unless from_unmount
        end
        @head = t(:p, {} ) unless preserve
        @body = t(:div, {}) unless preserve

        Element.find("body").remove_class("modal-open") if (@@opened_count <= 0)
        set_state display: "none" unless from_unmount
        if @on_close
          @on_close.call()
        end
      end

      def drag(e)
        @dragged_elem.style.top = "#{@dragged_elem_X + `e.pageY`}px"
      end

      def component_will_unmount
        close(false, true)
      end

  	end
  end
end
