class FromUrlProxyImage < ActiveRecord::Base
  belongs_to :user

  has_attached_file :file, styles: {
    post_size: {geometry: "800x", convert_options: '-quality 75 -strip'}
  }

  validates_attachment :file, presence: true,
                              content_type: {content_type: ["image/jpeg", "image/png"]},
                              #file_name: {matches: [/png\Z/, /jpe?g\Z/, /blob/]},
                              size: { less_than: 2.megabytes }


  def file_url
    self.file.url(:post_size)
  end

  def post_size_url
    self.file_url
  end

end
