class Post < ActiveRecord::Base

  #include PgSearch
  #pg_search_scope :search_by_title, :against => :title, using: {tsearch: {prefix: true}}

  attr_accessor :_tmp_id 

  class Constants

    KARMA_MULTIPLIER = 5

  end

  def arbitrary
    @_arbitrary ||= {}
  end

  include ModelValidator::CustomErrorable

  #SERIALIZED COLUMNS
  #used for storing the order of post nodes in post
  serialize :nodes_order, Array

  #END SERIALIZED COLUMNS

  #FULLTEXTSEARCH RELATED
  def self.post_tsv_options
    @post_tsv_options ||=  {
      searchable_type: 'Post',
      searchable_attribute: :title,
      default_tsv_weight: 'A',
      default_tsv_dictionary: 'russian'
    }
  end
  #END FULLTEXTSEARCH RELATED

  #ASSOCIATIONS
  belongs_to :author, class_name: 'User', foreign_key: :author_id
  belongs_to :au_s_id, ->{select(:id)}, class_name: 'User', foreign_key: :author_id

  has_many :post_thumbs, dependent: :destroy


  has_many :post_nodes, dependent: :destroy, inverse_of: :post
  has_many :post_texts, through: :post_nodes, source: :node, source_type: 'PostText'
  has_many :post_images, through: :post_nodes, source: :node, source_type: 'PostImage'

  has_many :post_tag_links, dependent: :destroy
  has_many :post_tags, through: :post_tag_links

  has_one :post_type_link, dependent: :destroy
  has_one :post_type, through: :post_type_link

  has_one :discussion, as: :discussable
  has_one :post_karma, dependent: :destroy

  has_many :post_tsvs, dependent: :destroy

  has_many :user_subscriptions, primary_key: :author_id, foreign_key: :to_user_id

  #END ASSOCIATIONS

  #VALIDATES ASSICIATED LIST
  validates_associated :post_nodes, :post_thumbs

  #VALIDATE ASSOSIATED LIST

  #       SERVICE ACCESSORS

  def self.qo_service
    ModelQuerier::Post.new
  end


  def self.composer_helper
    Services::Post::ComposerHelper
  end

  def composer_helper
    @composer_helper ||= Services::Post::ComposerHelper.new(self)
  end

  def qo_service
    ModelQuerier::Post.new(self)
  end

  def updater
    @updater ||= Services::Post::Updater.new(self)
  end

  def serialize_service
    @_serialize_service ||= PostSubclassServices::Serialize.new(self)
  end



  def validation_service
    @_validation_service ||= ModelValidator::Post.new(self)
  end

  #        END SERVICE ACCCESSORS





  #     SERIALIZATION RELATED
  #returns serialized post_nodes
  def post_nodes_with_root
    serialize_service.post_nodes_serialized
  end


  #END SERIALIZATION RELATED
require "benchmark"
  def self.test_traditional

    posts = nil
    puts Benchmark.measure {
      100.times {
      posts = Post.all.includes({author: [:user_credential]}, {post_karma: [:post_karma_transactions]})

      posts = posts.as_json(include: [{author: {includes: [:user_credential]}}, {post_karma: {include: [:post_karma_transactions]}}])
    }
    }
    byebug
  end

  def self.test_new

puts Benchmark.measure {

  100.times {
    base_con = ActiveRecord::Base.connection ;
    posts = base_con.execute('select * from posts') ;

    author_ids = posts.values.map {|val| val[4]};
    author_ids = author_ids.join(',') ;
    users = base_con.execute("select * from users where id in (#{author_ids})");

    user_ids = users.values.map {|val| val[0]} ;
    user_ids = user_ids.join(',') ;

    user_credentials = base_con.execute("select * from user_credentials where user_id in (#{user_ids})");

    post_ids = posts.values.map {|val| val[0]} ;
    post_ids = post_ids.join(',') ;
    post_karmas = base_con.execute("select * from post_karmas where post_id in (#{post_ids})") ;

    post_karma_ids = post_karmas.values.map {|val| val[0]} ;
    post_karma_ids = post_karma_ids.join(',') ;

    post_karma_transactions = base_con.execute("select * from post_karma_transactions where post_karma_id in (#{post_karma_ids})") ;

    result = {
      posts: {
        vs: posts.values,
        fs: posts.fields,
        as: [
          {
            author: {
              fs: users.fields,
              vs: users.values,
              as: [
                {
                  user_credential: {
                    fs: user_credentials.fields,
                    vs: user_credentials.values
                  }
                }
              ]
            }
          },
          post_karmas: {
            vs: post_karmas.values,
            fs: post_karmas.fields,
            as: [
              {
                post_karma_transactions: {
                  vs: post_karma_transactions.values,
                  fs: post_karma_transactions.fields
                }
              }
            ]
          }
        ]
      }
    }.to_json
  }
  }
  byebug
  end

end
