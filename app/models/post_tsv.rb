class PostTsv < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :post
  belongs_to :searchable
  #END ASSOCIATIONS

  include PgSearch
  pg_search_scope :post_full_text_search,
                 {
                    against: :content,
                    using: {
                      tsearch: {
                        dictionary: 'russian',
                        tsvector_column: 'tsv_content',
                        any_word: true
                      }
                    },
                    order_within_rank: "post_tsvs.updated_at DESC"
                 }



  # def self.ft_search(query)
  #   query = query.split(' ').join(' | ')
  #   to_ts = "to_tsquery('russian', #{self.sanitize(query)})"

  #   self
  #   .select("post_tsvs.*, ts_rank(post_tsvs.tsv_content, #{to_ts}) as rank")
  #   .where("post_tsvs.tsv_content @@ to_tsquery('russian', ?)", query)
  #   .order('rank desc, post_tsvs.updated_at desc')
  # end

end


