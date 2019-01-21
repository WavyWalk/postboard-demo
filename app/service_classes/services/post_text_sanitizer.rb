class Services::PostTextSanitizer
  
  def self.sanitize_post_text_content(content)
    
    content ||= ''

    content.strip!

    content.squeeze!(' ')

    content = Sanitize.fragment(content,
      :elements => ['a', 'h3', 'p'],

      :attributes => {
        'a'    => ['href', 'title']
      },

      :protocols => {
        'a' => {'href' => ['http', 'https', 'mailto']}
      },

      :add_attributes => {
        'a' => {'rel' => 'nofollow'}
      }

    )

  end
  
end
