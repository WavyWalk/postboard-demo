class PostText < ActiveRecord::Base

  include ModelValidator::CustomErrorable
  #ASSOCIATIONS
  has_one :post_node, as: :node
  has_one :post, through: :post_node
  has_one :post_thumb, as: :node
  has_many :post_tsvs, as: :searchable, dependent: :destroy
  #END ASSOCIATIONS

  #accessors
  #needed for cases when post_node_id needs to be rendered when calling to json
  #eg.
  #instace.post_node_id = 1
  #instance.as_json(methods: [:post_node_id])
  attr_accessor :post_node_id, :_tmp_id, :_should_destroy, :_changed
  #end accessors

  def arbitrary
    @_arbitrary ||= {}
  end

  # =>    SERVICE ACCESSORS

  def validation_service
    @validation_service ||= ModelValidator::PostText.new(self)
  end

  def self.factory
    Services::PostText::Factory
  end

  def updater
    @updater_service ||= Services::PostText::Updater.new(self)
  end

  def helpers
    @helpers ||= Services::PostText::Helpers.new(self)
  end

  # =>      END SERVICE ACCESSORS

  #this reader is neccessary for Services::PostTsv.initialize_post_tsv
  def self.post_tsv_options
    @post_tsv_options ||= {
      searchable_attribute: :content,
      searchable_type: 'PostText',
      default_tsv_weight: 'B',
      default_tsv_dictionary: 'russian'
    }
  end


  def json_for_thumb
    self.as_json
  end


  def json_for_post_node
    self.as_json
  end

  def json_for_post_node_er
    self.as_json(methods: [:errors])
  end


end
