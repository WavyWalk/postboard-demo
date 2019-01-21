class PostImage < ActiveRecord::Base

  include ModelValidator::CustomErrorable
  #ASSOICIATIONS
  belongs_to :users
  has_many :post_thumbs, as: :node
  has_many :post_nodes, as: :node
  has_many :post_test_questions, as: :content
  has_many :post_tests, foreign_key: :thumbnail_id
  has_many :test_questions, as: :content
  has_many :test_questions, as: :on_answered_m_content
  has_many :test_answer_variants, as: :content
  has_many :post_vote_polls, as: :m_content
  has_many :vote_poll_options, as: :m_content
  #END ASSOICIATIONS

  attr_accessor :post_node_id, :_tmp_id, :_should_destroy, :_changed

  def arbitrary
    @_arbitrary ||= {}
  end

  def self.qo
    ModelQuerier::PostImage.new(self)
  end

  def self.factory
    Services::PostImage::Factory
  end

  def self.composer_helper
    Services::PostImage::ComposerHelper
  end

  def serialization_helper_service
    @serialization_helper_service ||= Services::PostImage::SerializationHelper.new(self)
  end

  def updater
    @updater ||= Services::PostImage::Updater.new(self)
  end

  def validation_service
    @validation_service ||= ModelValidator::PostImage.new(self)
  end
  #PAPERCLIP RELATED

  has_attached_file :file, styles: {
    post_size: {geometry: "800x", convert_options: '-quality 75 -strip'}
  }


  validates_attachment :file, presence: true,
                              content_type: {content_type: ["image/jpeg", "image/png"]},
                              #file_name: {matches: [/png\Z/, /jpe?g\Z/, /blob/]},
                              size: { less_than: 2.megabytes }


  #extracts and saves post_size file dimensions in dimensions attribute
  #as string in format "#{width}x#{height}"
  before_save :get_and_set_post_size_dimensions

  #END PAPERCLIP RELATED
  def post_size_url
    self.file.url(:post_size)
  end

  def base_url
    self.file.url
  end

  def json_for_thumb
    self.as_json(methods: [:post_size_url])
  end

  def json_for_post_node
    self.as_json(methods: [:post_size_url])
  end

  def json_for_post_node_er
    self.as_json(methods: [:post_size_url, :errors])
  end

private



  #refer to before_save callback
  def get_and_set_post_size_dimensions

    tempfile = file.queued_for_write[:post_size]

    if tempfile

      geometry = Paperclip::Geometry.from_file(tempfile)

      self.dimensions = "#{geometry.width.to_i}x#{geometry.height.to_i}"

    end

  end

end
