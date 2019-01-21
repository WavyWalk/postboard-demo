class AsJsonSerializer::PostTags::Autocompletes::Index

  def initialize(post_tags)
    @post_tags = post_tags
  end

  def success

    @post_tags.as_json(only: [:id, :name])
    
  end

end