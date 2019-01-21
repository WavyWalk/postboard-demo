class Services::VotePollOption::Factory

  def self.build_from_attributes_for_create(attributes)
    vp_o = ::VotePollOption.new
    vp_o.content = attributes['content']
    if content = attributes['m_content']
      vp_o.m_content_id = content['id']
      vp_o.m_content_type = 'PostImage'
    end
    vp_o.count = 0
    vp_o
  end

end