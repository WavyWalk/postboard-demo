class PostGif < ActiveRecord::Base


  attr_accessor :post_node_id, :_tmp_id, :_should_destroy, :_changed

  include ModelValidator::CustomErrorable
  #ASSOCIATIONS
  has_many :post_thumbs, as: :node
  has_many :post_nodes, as: :node
  belongs_to :user
  #END ASSOICIATIONS
  #PAPERCLIP RELATED
  has_attached_file :file, styles: {
                    post_gif: {
                      processors: [:gif_to_video], format: 'ogg'
                    }
                  }

  validates_attachment :file, presence: true,
                       content_type: {content_type: ["image/gif"]},
                       file_name: {matches: [/gif\Z/]},
                       size: {less_than: 4.megabytes}

  #END PAPERCLIP RELATED

  #services accessors
  def self.qo
    ModelQuerier::PostGif.new(self)
  end

  def self.composer_helper
    Services::PostGif::ComposerHelper
  end

  def updater_service
    @updater_service ||= Services::PostImage::Updater.new(self)
  end

  def validation_service
    @validation_service ||= ModelValidator::PostGif.new(self)
  end

  def self.factory
    Services::PostImage::Factory
  end
  #end services attr_accessors

  before_save :get_and_set_dimensions_for_post_gif


  def get_and_set_dimensions_for_post_gif

    temp_file = file.queued_for_write[:post_gif]

    if temp_file && temp_file_path = temp_file.path

      resolution = FFMPEG::Movie.new(temp_file_path).resolution
      self.dimensions = resolution

    end

  end

  def base_url
    self.file.url
  end

  def post_gif_url
    self.file.url(:post_gif)
  end

  def json_for_thumb
    self.as_json(methods: [:post_gif_url])
  end


  def json_for_post_node
    self.as_json(methods: [:post_gif_url])
  end

  def json_for_post_node_er
    self.as_json(methods: [:post_gif_url, :errors])
  end

end
