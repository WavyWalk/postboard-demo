class Services::Post::ComposerHelper





    def initialize(owner)
      @owner = owner
    end






    def persist_tsvs_for_create
      post_tsvs = []
      post_tsvs << Services::PostTsv.initialize_post_tsv(model: @owner, post_id: @owner.id)

      @owner.post_nodes.each do |post_node|
        if post_node.node_type == 'PostText'
          post_tsvs << Services::PostTsv.initialize_post_tsv(model: post_node.node, post_id: @owner.id)
        end
      end

      post_tsvs.each do |p_tsv|
        p_tsv.save!
      end
    end







    def build_and_persist_post_thumbs_for_post_create!(post_thumbs_hash)
      
      if post_thumbs_hash.is_a?(Array) && !post_thumbs_hash.empty?
        persist_post_thumbs_from_hash(post_thumbs_hash)
      else
        extract_and_persist_thumbs_from_post_nodes
      end


    end






    def extract_and_persist_thumbs_from_post_nodes
      post_thumbs = []

      thumbable = ['PostImage']

      if (node = @owner.post_nodes[0].node).is_a?(PostText)

        first_tag = node.helpers.extract_first_readable_tag
        first_thumb = ::PostThumb.new
        first_thumb.node = ::PostText.new(content: first_tag)

        post_thumbs << first_thumb


        @owner.post_nodes.each_with_index do |pn, index|

          next if index == 0

          if thumbable.include?(pn.node_type)

            post_thumb = ::PostThumb.new
            post_thumb.node = pn.node
            post_thumbs << post_thumb

            break

          end

        end

      else

        @owner.post_nodes.each do |post_node|
          if thumbable.include?(post_node.node_type)
            post_thumb = ::PostThumb.new
            post_thumb.node = post_node.node
            post_thumbs << post_thumb
            break
          end
        end

      end

      @owner.post_thumbs << post_thumbs
      @owner.save!

    end




    def persist_post_thumbs_from_hash(post_thumbs_hash)
      post_thumbs_hash.each do |post_thumb|
        @owner.post_thumbs << ::PostThumb.factory.initialize_with_node_when_creating_post(post_thumb)
      end
      @owner.save!
    end





end
