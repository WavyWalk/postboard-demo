module Plugins
  module InfiniteScrollable

    def extract_pagination(collection)
      if (x = collection.data[-1].attributes[:pagination])
        x = Pagination.new(collection.data.pop.attributes[:pagination])
        self.state.pagination = x
      end
    end

    def pagination_current_page
      state.pagination.current_page
    end

    def next_page_infinite_scroll_beacon(last_index)
      return nil if ( (@last_index == last_index) || `#{last_index} === undefined` || !last_index )
      @last_index = last_index
      destroy_infinite_scroll_beacon

      @beacon_count ||= 0
      @beacon_count += 1
      @beacon_count
      @last_beacon = "infinite_scroll_beacon#{@beacon_count}"

      t(:div, {ref: @last_beacon},

      )

    end

    def listen_to_infinite_scroll_beacon
      @beacon_element = ref("last_beacon")
      if @beacon_waypoint
        @beacon_waypoint.destroy
      end
      if @beacon_element
        @beacon_waypoint = Waypoint.new(
          element: @beacon_element,
          handler: ->(direction){ handle_infinite_croll_beacon_reach },
          offset: '110%'
        )
      end
    end

    def destroy_infinite_scroll_beacon
      if @beacon_waypoint
        @beacon_waypoint.destroy
      end
    end

    def handle_infinite_croll_beacon_reach

    end


  end
end
