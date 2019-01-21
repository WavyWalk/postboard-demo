module Components
  module PostTexts
    class New < RW
    
      expose

      include Plugins::Formable

      def get_initial_state
        post_text = n_prop(:post_text) || PostText.new
        {
          post_text: post_text
        }
      end

      def render
        post_text = n_state(:post_text)

        t(:div, {className: 'post-texts-new'},
          general_errors_for(n_state(:post)),

          input(Components::Forms::WysiTextarea, post_text, :content, {}),
          t(:button, {className: 'btn btn-primary btn-sm', onClick: ->{handle_submit}},
            "create"
          )
        )  
      end

      def handle_submit
        collect_inputs(form_model: n_state(:post_text))

        if n_prop(:on_collect)
          n_prop(:on_collect).call(n_state(:post_text), self)
          return
        end

        n_state(:post_text).create do |post_text|
          force_update
        end

      end


    end
  end
end 


