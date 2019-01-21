class PostType < ActiveRecord::Base

  POST_TYPES = [
    {name: 'funny', alt_name: 'funny'},
    {name: 'news', alt_name: 'news'},
    {name: 'health & beauty', alt_name: 'health & beauty' },
    {name: 'review', alt_name: 'review'},
    {name: 'coolstory', alt_name: 'coolstory'},
    {name: 'celebrities', alt_name: 'celebrities'},
    {name: 'gaming', alt_name: 'gaming'},
    {name: 'food', alt_name: 'food'},
    {name: 'fun facts', alt_name: 'fun facts'},
    {name: 'gadgets', alt_name: 'gadgets'},
    {name: 'test', alt_name: 'test'},
  ]

  has_many :post_type_links
  has_many :posts, through: :post_type_links


  def self.qo
    ModelQuerier::PostType.new
  end

  def self.as_json_serializer
    AsJsonSerializer::PostType
  end


  def self.populate_post_types
    POST_TYPES.each do |type_value|
      PostType.where(name: type_value[:name]).first_or_create do |type|
        type.name = type_value[:name]
        type.alt_name = type_value[:alt_name]
      end
    end

  end

end
