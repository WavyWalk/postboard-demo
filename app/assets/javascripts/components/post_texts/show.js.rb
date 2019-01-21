module Components
  module PostTexts
    class Show < RW
      expose

      #PROPS
      #REQUIRED:
      # :post_text : PostText < Model
      #OPTIONAL
      #truncate_text : boolean ; this prop is needed when long text should be truncated on pages where long representation is not necessary (post index)

      def validate_props
        if !props.post_text || !props.post_text.is_a?(PostText)
          puts "#{self} of #{self.class}: required_prop :post_text : PostText was not passed -> got #{props.post_text} of #{props.post_text.class} instead"
        end
      end

      def render
        t(:div, {dangerouslySetInnerHTML: {__html: props.post_text.content}.to_n, className: "post-text #{props.truncate_text ? 'truncate' : ''}"})
      end

    end
  end
end
