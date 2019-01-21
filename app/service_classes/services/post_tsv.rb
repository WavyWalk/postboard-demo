class Services::PostTsv

  def self.initialize_post_tsv(model:, post_id:)

    # !!!!!
    # "#{model.class.name} must have @post_tsv_options singleton instance var or reader
    #   with assigned options hash following
    #   {
    #    searchable_type: 'model.class.name',
    #    searchable_attribute: 'attribute_that should be saved for search',
    #    default_tsv_weight: 'weight value in ['A', 'B', 'C', 'D']',
    #    default_tsv_dictionary: 'dict name'
    #   }"

    if model.id

      post_tsv = ::PostTsv.where(post_id: post_id, searchable_type: model.class.post_tsv_options[:searchable_type], searchable_id: model.id)
                          .first_or_initialize

    else

      post_tsv = ::PostTsv.new(searchable_type: model.class.post_tsv_options[:searchable_type], post_id: post_id)

    end

    post_tsv.content = model.send( model.class.post_tsv_options[:searchable_attribute] )
    post_tsv.tsv_weight = model.class.post_tsv_options[:default_tsv_weight]
    post_tsv.tsv_options = model.class.post_tsv_options[:default_tsv_dictionary]

    post_tsv

  end


  def self.destroy_tsv!(model:, post_id:)
    ptsv = ::PostTsv.where(post_id: post_id, searchable_type: model.class.post_tsv_options[:searchable_type], searchable_id: model.id)
    if ptsv
      ptsv.destroy!
    end
  end

end
