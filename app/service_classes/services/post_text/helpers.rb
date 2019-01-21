class Services::PostText::Helpers

  def initialize(owner)
    @owner = owner
  end

  def extract_first_readable_tag

    content = Nokogiri::HTML @owner.content
    
    if (x = content.at('p')) && x.text
      content = x
    elsif (x = content.at('h3')) && x.text
      content = x
    end

    content

  end

end
