module Components
  module PostImages
    class CollageNew < RW
      expose
      include Plugins::Formable

      def validate_props
        #on_image_uploaded : ProcEvent # required
      end

      def get_initial_state
        @image_url = n_prop(:image_src)
        @boundaries_updated_event = event(->{draw})
        @canvas_width = 600
        @canvas_height = 600
        @boundary_id_counter = -1
        {
          boundaries: [],
          should_show_controlls_for_boundaries: true
        }
      end


      def render
        t(:div, {className: 'post-images-collage-new'},

          t(:form, {ref: "#{self}form"},
            t(:input, {onChange: ->{read_and_add_to_roster}, type: 'file', multiple: true, ref: "#{self}"})
          ),
          t(:div, {className: 'col-lg-12'},
            #t(:button, {onClick: ->{_draw}},'draw'),
            #t(:button, {onClick: ->{add_input_frame}}, 'add input'),
            n_state(:boundaries).map do |boundary|
              t(:img, {src: boundary[:image].JS[:src], style: `{width: '20px', height: '20px'}`})
            end,
            t(:p, {},
              "show frame",
              #this state passed to draggable. if true draggable will draw frame and resize controlls
              t(:input, {type: 'checkbox', checked: n_state(:should_show_controlls_for_boundaries), onChange: ->{toggle_should_show_controlls_for_boundaries}})
            ),
            t(:button, {onClick: ->{on_done}}, 'apply changes')
          ),
          t(:div, {className: 'block col-lg-12'},
            t(:div, {className: 'outerCanvasWrapper'}, 
              t(:div, {className: 'canvas-wrapper', style: `{position: 'relative', width: #{@canvas_width} + 'px', height: #{@canvas_height} + 'px'}`},
                t(:canvas, {className: 'canvas', ref: 'canvas', style: `{width: #{@canvas_width} + 'px', height: #{@canvas_height} + 'px'}`}),
                n_state(:boundaries).map do |model|
                  render_draggable(model)
                end
              )
            )
          )
        )
      end

      def read_and_add_to_roster
        `
        var files    = #{n_ref("#{self}")}.files;

        if (files.length > 0) {
          var i;
          for (i = 0; i < files.length; i++) {
            var file = files[i];
            var reader = new FileReader();

            reader.onloadend = function(){

              var image = new Image();
              image.onload = function(){
                #{add_image_to_roster(`image`)}
              }
              image.src = reader.result

            }

            if (file) {
              reader.readAsDataURL(file);
            }

          }
        }
        `
      end

      def reset_input
        n_ref("#{self}form").JS.reset()
      end

      def add_image_to_roster(image)
        boundaries = n_state(:boundaries)
        new_boundary = create_boundary(image)
        boundaries << new_boundary
        set_state boundaries: boundaries
        reset_input
        draw
      end

      def toggle_should_show_controlls_for_boundaries
        val = n_state(:should_show_controlls_for_boundaries)
        set_state should_show_controlls_for_boundaries: !val
      end

      def render_draggable(model)
        t(Draggable, {
          model: model,
          boundaries_changed: ->{force_update},
          should_show_controlls_for_boundaries: n_state(:should_show_controlls_for_boundaries),
          boundaries_updated: @boundaries_updated_event
        })
      end

      def on_done
        image = n_ref(:canvas).JS.toDataURL()
        emit(:on_done, image)
      end

      ##############
      ############
      ##############

      def create_boundary(image)
        initial_width = @canvas_width * 0.9
        initial_height = 100
        {
          id: (@boundary_id_counter += 1),
          boundaries_height: @canvas_height,
          boundaries_width: @canvas_width,
          top: `#{@canvas_height} / 3`,
          left: (`(#{@canvas_width} - #{initial_width}) / 2`),
          height: initial_height,
          width: initial_width,
          image: image
        }
      end


      def component_did_mount
        @canvas = n_ref('canvas')
        @canvas.JS[:width] = @canvas_width
        @canvas.JS[:height] = @canvas_height
        @ctx = @canvas.JS.getContext('2d')

        grab_image_from_prop
      end

      def grab_image_from_prop
        image_src = n_prop(:image_src)
        `
        var image = new Image();
        image.onload = function(){
          #{add_image_to_roster(`image`)}
        }
        image.src = #{image_src}
        `
      end


      def draw
        clear_canvas
        n_state(:boundaries).each do |boundary|
          draw_boundary(boundary)
        end
      end


      def clear_canvas
        @ctx.JS.clearRect(0, 0, @canvas_width, @canvas_height)
      end


      def draw_boundary(boundary)
        @ctx.JS.drawImage(boundary[:image], boundary[:left], boundary[:top], boundary[:width], boundary[:height])
      end


    end
  end
end
