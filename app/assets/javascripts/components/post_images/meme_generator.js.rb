module Components
  module PostImages
    class MemeGenerator < RW
      expose

      include Plugins::Formable

      def get_initial_state
        @canvas_should_display = 'none'
        @image_url = n_prop(:image_src)
        @boundaries_updated_event = event(->{draw})
        {
          boundaries: ModelCollection.new,
          should_show_controlls_for_boundaries: true
        }
      end


      def render
        t(:div, {className: 'memegenerator row'},
          t(:div, {className: 'block col-lg-6'},
            t(:div, {className: 'canvas-wrapper', style: `{position: 'relative', width: #{@canvas_width} + 'px', height: #{@canvas_height} + 'px'}`},
              t(:canvas, {className: 'canvas', ref: 'canvas', display: @canvas_should_display}),
              if @canvas_should_display == ''
                n_state(:boundaries).map do |model|
                  render_draggable(model)
                end
              end
            )
          ),
          t(:div, {className: 'inputs col-lg-6'},
            #t(:button, {onClick: ->{_draw}},'draw'),
            t(:button, {onClick: ->{add_input_frame}}, 'add input'),
            n_state(:boundaries).data.map do |boundary|
              input(Components::Forms::Input, boundary, :text, {on_change: ->{_draw}})
            end,
            t(:p, {},
              "show frame",
              #this state passed to draggable. if true draggable will draw frame and resize controlls
              t(:input, {type: 'checkbox', checked: n_state(:should_show_controlls_for_boundaries), onChange: ->{toggle_should_show_controlls_for_boundaries}})
            ),
            t(:button, {onClick: ->{on_done}}, 'apply changes')
          )
        )
      end

      def toggle_should_show_controlls_for_boundaries
        val = n_state(:should_show_controlls_for_boundaries)
        set_state should_show_controlls_for_boundaries: !val
      end

      def on_done
        image = n_ref(:canvas).JS.toDataURL()
        emit(:on_done, image)
      end

      def add_input_frame
        n_state(:boundaries) << Model.new(top_boundary_model_attributes)
        force_update
      end

      def render_draggable(model)
        t(Draggable, {boundaries_updated: @boundaries_updated_event, model: model, boundaries_changed: ->{force_update}, should_show_controlls_for_boundaries: n_state(:should_show_controlls_for_boundaries)})
      end

      def top_boundary_model_attributes
        initial_width = @canvas_width * 0.9
        initial_height = 30 #line height
        {
          boundaries_height: @canvas_height,
          boundaries_width: @canvas_width,
          top: `#{@canvas_height} / 3`,
          left: (`(#{@canvas_width} - #{initial_width}) / 2`),
          height: initial_height,
          width: initial_width,
          text: '',
          line_height: initial_height,
          boundaries_updated: @boundaries_updated_event,
          font_size: initial_height * 0.9,
          font_type: 'Impact'
        }
      end

      def scale_image_dimensions_for_width(current_height, current_width, new_width)
        new_height = (current_height / current_width) * new_width
        return {new_height: new_height, new_width: new_width}
      end

      def component_did_mount
        `
          var image = new Image();
          image.onload = function(){
            #{image_onload(`image`)};
          };
          image.src = #{@image_url}
        `
        @ctx = n_ref('canvas').JS.getContext('2d')
      end

      def image_onload(image)
        @image = image

        @actual_image_height = image.JS[:height]
        @actual_image_width = image.JS[:width]

        available_width = `$('.block')[0].offsetWidth` || 400

        new_dimensions = scale_image_dimensions_for_width(@actual_image_height, @actual_image_width, available_width - 10)

        @image_height = new_dimensions[:new_height]
        @image_width = new_dimensions[:new_width]

        @canvas_width = @image_width
        @canvas_height = @image_height

        @line_height = 20

        n_ref('canvas').JS[:width] = @canvas_width
        n_ref('canvas').JS[:height] = @canvas_height

        @canvas_should_display = ''

        draw
      end

      def _draw
        collect_inputs(validate: false)
        draw
      end

      #TODO: Should be deleted probably
      def cs_a
        n_state(:canvas_state).attributes
      end

      def draw
        clear_canvas
        draw_image
        n_state(:boundaries).each do |boundary|
          fill_text_within_boundaries(boundary)
        end
      end

      def clear_canvas
        @ctx.JS.clearRect(0, 0, @image_width, @image_height)
      end

      def draw_image
        @ctx.JS.drawImage(
          @image, 0, 0, @actual_image_width, @actual_image_width,
                  0, 0, @canvas_width      , @canvas_height
        )
      end

      def fill_text_within_boundaries(boundary)
        @ctx.JS[:font] = "#{boundary.attributes[:font_size]}px #{boundary.attributes[:font_type]}"

        if boundary.attributes[:text]

          lines = get_lines(boundary)

          height_and_potential_height_difference = ( boundary.attributes[:height] - (lines.length * boundary.attributes[:font_size]) )

          if height_and_potential_height_difference <= 0
            boundary.attributes[:font_size] = `#{boundary.attributes[:font_size]} * 0.9`
            fill_text_within_boundaries(boundary)
            return
          elsif height_and_potential_height_difference >= boundary.attributes[:font_size]
            boundary.attributes[:font_size] = `#{boundary.attributes[:font_size]} * 1.1`
            fill_text_within_boundaries(boundary)
            return
          end

          write_lines(lines, boundary)
        end
      end

      # def print_line(text, height)
      #   @ctx.JS.fillText(text, height)
      # end

      def get_lines(boundary)
        text = boundary.attributes[:text]
        line_text = ''
        line_index = 0
        lines_ary = []
        text.split(' ').each do |word|
          if line_width_exceeds_boundaries("#{line_text} #{word}", boundary.attributes[:width])
            lines_ary[line_index] = line_text
            line_index = `#{line_index} + 1`
            line_text = word
          else
            line_text = "#{line_text} #{word}"
          end
        end
        lines_ary << line_text
        lines_ary
      end

      def line_width_exceeds_boundaries(text, width)
        measure_text_width(text) > width
      end

      def measure_text_width(text)
        @ctx.JS.measureText(text).JS[:width]
      end

      def write_lines(lines, boundary)

        current_y = `#{boundary.attributes[:top]} + #{boundary.attributes[:font_size]}`


        #@ctx.JS[:shadowOffsetX] = 2;
        #@ctx.JS[:shadowOffsetY] = 1;
        @ctx.JS[:shadowBlur] = 10;
        @ctx.JS[:shadowColor] = 'black'
        @ctx.JS[:fillStyle] = 'white'
        lines.each do |line|
          line_width = measure_text_width(line)
          x = ((boundary.attributes[:width] - line_width) / 2) + boundary.attributes[:left]
          @ctx.JS.fillText(line, x, current_y)
          `#{current_y} += #{boundary.attributes[:font_size]}`
        end
      end

    end
  end
end
