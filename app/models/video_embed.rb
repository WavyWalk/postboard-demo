class VideoEmbed < ActiveRecord::Base

  include ModelValidator::CustomErrorable

  attr_accessor :post_node_id, :_tmp_id, :_should_destroy, :_changed

  ALLOWED_PROVIDER_NAMES = ['youtube']

  YOUTUBE_REGEX = /^(\/\/)?(?:https?:\/\/)?(?:m\.|www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/


  has_many :post_nodes, as: :node
  has_many :post_thumb, as: :node

  # SERVICE ACCESSORS
  def validation_service
    @validation_service ||= ModelValidator::VideoEmbed.new(self)
  end

  def updater
    @updater ||= Services::VideoEmbed::Updater.new(self)
  end

  def base_url
    self.link
  end

  def json_for_post_node
    self.as_json
  end

  def json_for_post_node_er
    self.as_json(methods: [:errors])
  end

  def json_for_thumb
    self.as_json
  end
  # END SERVICE ACCESSORS

end
