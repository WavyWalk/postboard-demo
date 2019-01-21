module Components
  module PostTexts
    class Edit < RW
      expose

      include Plugins::Formable

      def render
        post_text = n_prop(:post_text)

       t(:div, {className: 'post-texts-new post-texts-edit'},
          input(Components::Forms::WysiTextarea, post_text, :content, {on_change: ->{handle_content_change}}),
          if post_text.attribute_was_changed?(:content)
            t(:button, {className: 'btn btn-primary btn-sm', onClick: ->{update}}, 'update')
          end          
        )        
      end

      def handle_content_change
        post_text = n_prop(:post_text)
        unless post_text.attribute_was_changed?(:content)
          post_text.record_change_for_attribute(:content)
          force_update
        end
      end

      def update
        collect_inputs
        start_spinning_icon
        n_prop(:post_text).update(namespace: 'staff').then do |post_text| 
          stop_spinning_icon
          begin
          unless post_text.has_errors?
            post_text.clear_change_record_for_attribute(:content)
          end
          force_update
          rescue Exception => e
            `console.log(#{e})`
          end
        end
      end      

    end
  end
end