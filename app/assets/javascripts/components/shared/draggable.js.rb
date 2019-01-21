#DRAGGABLE SNIPPET!
class Draggable < RW

  expose
  def init
    drag_model[:component] = self
  end

  def render
    t(:div, {className: 'foo', style: get_style,
             ref: 'drag', onMouseDown: ->(e){start_dragging(e)}},
      if n_prop(:should_show_controlls_for_boundaries)
        t(:i, {onMouseDown: ->(e){resize_elem(e)}, className: 'icon-resize-full resize-field-button', style: `{cursor: 'se-resize', position: 'absolute', bottom: 0, right: 0, margin: 0, padding: 0, width: '1em', height: '1em', 'font-size': '0.8em', 'line-height': '0.8em'}`})
      end
    )
  end

  def resize_elem(e)
    start_resizing(e)
    e.JS.stopPropagation()
  end

  def set_mouse_down_initial_coords(e)
    @mouse_down_initial_x = e.JS[:pageX]
    @mouse_down_initial_y = e.JS[:pageY]
  end


  def start_resizing(e)
    set_mouse_down_initial_coords(e)
    listen_for_mouse_move_on_resize(e)
  end

  def listen_for_mouse_move_on_resize
    `
    $(document).on("mouseup.resize" + #{self}, function(e){
      #{ off_mouse_move_for_resize_event };
      #{ off_mouse_up_for_resize_event };
    });
    $(document).on("mousemove.resize" + #{self}, function(e){
      #{`return` if @processing}
      #{@processing = true}
      changeX = e.pageX - #{@mouse_down_initial_x};
      changeY = e.pageY - #{@mouse_down_initial_y} ;

      #{set_mouse_down_initial_coords(`e`)}

      if ( !(#{exceeds_boundaries_width_when_resize(`changeX`)}) ) {
        #{drag_model[:width] = `#{drag_model[:width]} + changeX`};

      };
      if ( !(#{exceeds_boundaries_height_when_resize(`changeY`)}) ) {
        #{drag_model[:height] =  `#{drag_model[:height]} + changeY`};

      };
      #{redraw}
    })
    `
  end


  def exceeds_boundaries_width_when_resize(change_x)
    %x{
      if ( (#{drag_model[:width]} + #{change_x} + #{drag_model[:left]}) > #{drag_model[:boundaries_width]}) {
        return true
      } else {
        return false
      }
    }
  end


  def exceeds_boundaries_height_when_resize(change_y)
    %x{
      if ( (#{drag_model[:height]} + #{change_y} + #{drag_model[:top]}) > #{drag_model[:boundaries_height]}) {
        return true
      } else {
        return false
      }
    }
  end


  def get_style
    ` var styles =  {
        position: 'absolute',
        height: #{drag_model[:height]},
        width: #{drag_model[:width]},
        top: #{drag_model[:top]},
        left: #{drag_model[:left]},
        padding: 0,
        margin: 0,
        'z-index': 999,
        cursor: 'pointer',
        cursor: 'pointer'
      };

      if (#{n_prop(:should_show_controlls_for_boundaries)}) {
        styles['border'] = '1px solid grey';
      };

      return styles

    `
  end

  def drag_model
    if n_prop(:model).is_a?(Model)
      n_prop(:model).attributes
    else
      n_prop(:model)
    end
  end

  def start_dragging(e)
    set_mouse_down_initial_coords(e)
    @drag_start_left = drag_model[:left]
    @drag_start_top = drag_model[:top]
    listen_for_mouse_move_on_drag
  end

  def listen_for_mouse_move_on_drag
    `
    $(document).on("mouseup.drag" + #{self}, function(e){
      #{ off_mouse_move_for_drag_event };
      #{ off_mouse_up_for_drag_event };

    });
    $(document).on("mousemove.drag" + #{self}, function(e){
      changeX = e.pageX - #{@mouse_down_initial_x};
      changeY = e.pageY - #{@mouse_down_initial_y} ;

      if ( !(#{exceeds_boundaries_width(`changeX`)}) ) {
        #{drag_model[:left] = `#{@drag_start_left} + changeX`};
      };
      if ( !(#{exceeds_boundaries_height(`changeY`)}) ) {
        #{drag_model[:top] =  `#{@drag_start_top} + changeY`};
      };
      #{redraw}
    })
    `
  end

  def redraw
    force_update
    emit(:boundaries_updated)
    @processing = false
  end

  def component_did_mount
    redraw
  end

  def exceeds_boundaries_height(to_add_to_top)
    `
      var testHeight = (#{@drag_start_top} + #{to_add_to_top})
      if ( (#{drag_model[:boundaries_height]} > (testHeight + #{drag_model[:height]})) && testHeight > 0 ) {
        return false
      } else {
        return true
      }
    `
  end

  def exceeds_boundaries_width(to_add_to_left)
    %x{
      var testWidth = #{@drag_start_left} + to_add_to_left
      if ( #{drag_model[:boundaries_width]} > (testWidth + #{drag_model[:width]}) && testWidth > 0 ) {
        return false
      } else {
        return true
      }
    }
  end

  def off_mouse_move_for_drag_event
    `
    $(document).off("mousemove.drag" + #{self})
    `
  end

  def off_mouse_up_for_drag_event
    `$(document).off("mouseup.drag" + #{self});`
  end

  def off_mouse_move_for_resize_event
    `$(document).off("mousemove.resize" + #{self})`
  end

  def off_mouse_up_for_resize_event
    `$(document).off("mouseup.resize" + #{self})`
  end


  def component_will_unmount
    off_mouse_move_for_drag_event
    off_mouse_up_for_drag_event
  end

  def component_did_mount
    @drag_el = n_ref(:drag)
  end

end

# var dragObj = null;
# var prevX = null
# var prevY = null

# function draggable(id)
# {
#     var obj = document.getElementById(id);
#     obj.style.position = "absolute";
#     obj.onmousedown = function(e){
#             dragObj = obj;
#             if (prevX === null && prevY === null) {
#               prevX = e.pageX
#               prevY = e.pageY
#             }
#     }
# }

# document.onmouseup = function(e){
#     dragObj = null;

# };
# document.onmousemove = function(e){
#     if(dragObj == null) return

#     var x = e.pageX;
#     var y = e.pageY;

#     dragObj.style.left = (x - prevX) + "px";
#     dragObj.style.top= (y - prevY) + "px";
# };
