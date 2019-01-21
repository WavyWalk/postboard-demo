class ComposerFor::Staff::UserSubmitted::Posts::Update < ComposerFor::Base


  def initialize(params:, controller: false)

    @params = params
    @controller = controller

  end


##################################



  def before_compose

    set_permitted_attributes

    find_and_set_post

    set_existing_post_nodes

    set_existing_post_thumbs

    if post_is_changed?
      apply_changes_to_post #Post.mutator_service.update(changes.map |k, v| k => v[:to]).get_instance
    end

    prepare_nodes

    prepare_post_thumbs

    handle_post_type

    validate_post

  end




  def set_permitted_attributes
    @post_permitted_attributes = @params.require(:post)
     .permit(
          :id,
          :_changed,
          {
            author: [:id, user_credential: [:id, :name]]
          },
          :title
      )
    @post_nodes_permitted_attributes = @params.require(:post)
      .permit(
        {
          post_nodes: [
            {node:
              [
                :id, :content, :link
              ]
            },
            :node_type,
            :_should_destroy,
            :_changed,
            :_tmp_id,
            :id
          ]
        }
      )

    @post_tags_attributes = @params.require(:post)
      .permit(
        post_tags: [
          :name, :id, :_should_destroy
        ]
      )[:post_tags]

    @post_thumbs_permitted_attributes = @params.require(:post)
      .permit(
        {
          post_thumbs: [
            {
              node:
              [
                :id, :content, :link
              ]
            },
            :node_type,
            :_should_destroy,
            :_changed,
            :_tmp_id,
            :id
          ]
        }
      )

    @post_type_permitted_attributes = @params.require(:post)
      .permit(
        post_type: [:id]
      )
  end




  def find_and_set_post

    @post = Post.where(id: @params[:id]).includes(:post_tags).first

  end



  def set_existing_post_nodes
    @existing_post_nodes = ::PostNode.where(post_id: @post.id).includes(:node)
  end


  def set_existing_post_thumbs
    @existing_post_thumbs = ::PostThumb.where(post_id: @post.id).includes(:node)
  end

  #changes to post model
  def post_is_changed?
    if @post_permitted_attributes[:_changed]
      true
    end
  end


  def apply_changes_to_post
    @post.updater.update_when_staff_edit(@post_permitted_attributes)
  end

  #end changes to post model



  def prepare_nodes

    @changed_post_nodes = []

    @post_nodes_permitted_attributes[:post_nodes].each do |post_node|

      @changed_post_nodes << handle_node(post_node)

    end

  end



  def handle_node(post_node_hash) # (Hash) : void



    if post_node_hash[:_should_destroy] #record shall be destroyed

      post_node = find_post_node_in_existing_nodes(post_node_hash[:id])
      post_node.arbitrary[:_should_destroy] = true


    elsif !post_node_hash[:id] #record shall be created
      post_node = PostNode.factory.initialize_with_node_when_creating_post(post_node_hash)
      post_node.arbitrary[:create] = true

      post_node.node.validation_service.set_scenarios(:post_create).validate_and_propagate_errors_to_model

    elsif post_node_hash[:_changed] && post_node_hash[:id] #record shall be udpated

      post_node = find_post_node_in_existing_nodes(post_node_hash[:id])
      post_node.composer_helper.update_node_for_staff_update(post_node_hash[:node])
      post_node.arbitrary[:update] = true

      post_node.node.validation_service.set_scenarios(:staff_update).validate_and_propagate_errors_to_model


    else #do nothing

      post_node = find_post_node_in_existing_nodes(post_node_hash[:id])

    end

    post_node._tmp_id = post_node_hash[:_tmp_id]


    post_node


  end







  def find_post_node_in_existing_nodes(id)

    node_to_return = @existing_post_nodes.find do |post_node|
      post_node.id == id.to_i
    end

    node_to_return

  end










  def prepare_post_thumbs

    @changed_post_thumbs = []

    @post_thumbs_permitted_attributes[:post_thumbs].each do |post_thumb|

      @changed_post_thumbs << handle_post_thumb(post_thumb)

    end

  end




  def handle_post_thumb(post_thumb_hash) # (Hash) : void



    if post_thumb_hash[:_should_destroy] #record shall be destroyed

      post_thumb = find_post_thumb_in_existing_nodes(post_thumb_hash[:id])
      post_thumb.arbitrary[:_should_destroy] = true


    elsif !post_thumb_hash[:id] #record shall be created
      post_thumb = PostThumb.factory.initialize_with_node_when_creating_post(post_thumb_hash)
      post_thumb.arbitrary[:create] = true

      post_thumb.node.validation_service.set_scenarios(:post_create).validate_and_propagate_errors_to_model

    elsif post_thumb_hash[:_changed] && post_thumb_hash[:id] #record shall be udpated

      post_thumb = find_post_thumb_in_existing_nodes(post_thumb_hash[:id])
      post_thumb.composer_helper.update_node_for_staff_update(post_thumb_hash[:node])
      post_thumb.arbitrary[:update] = true

      post_thumb.node.validation_service.set_scenarios(:staff_update).validate_and_propagate_errors_to_model


    else #do nothing

      post_thumb = find_post_thumb_in_existing_nodes(post_thumb_hash[:id])

    end

    post_thumb._tmp_id = post_thumb_hash[:_tmp_id]


    post_thumb


  end




  def handle_post_type
    existing_post_type = @post.post_type
    
    if x = @post_type_permitted_attributes["post_type"]
      post_type_id = x['id']
    end

    if existing_post_type && ( existing_post_type.id != post_type_id )
      if post_type_id
        @post.post_type = PostType.find(post_type_id)
      else
        @post.add_custom_error(:post_type, 'must be set')
      end
    end
  end




  def find_post_thumb_in_existing_nodes(id)
    post_thumb_to_return = @existing_post_thumbs.find do |post_thumb|
      post_thumb.id == id.to_i
    end

    post_thumb_to_return
  end






  def validate_post

    @post.validation_service.set_scenarios(:staff_update).validate_and_propagate_errors_to_model

  end






  def compose



    @changed_post_nodes.each do |post_node|

      if post_node.arbitrary[:_should_destroy]
        post_node.destroy!
        handle_after_destroy_post_node(post_node)
      end

    end

    @changed_post_thumbs.each do |post_thumb|
      if post_thumb.arbitrary[:_should_destroy]
        post_thumb.destroy!
        #handle_after_destroy_post_node(post_node)
      end
    end

    remove_destroyed_items_from(@changed_post_nodes)
    remove_destroyed_items_from(@changed_post_thumbs)


    ::Services::Post::Updater.concat_repeating_post_text_nodes_content_and_remove_unnecessary_from_collection(@changed_post_nodes)

    @changed_post_nodes.each do |post_node|

      if post_node.arbitrary[:update]

        post_node.node.save!
        handle_after_update_post_node(post_node)

      elsif post_node.arbitrary[:create]
        post_node.post_id = @post.id
        post_node.save!
        handle_after_create_post_node(post_node)

      end

    end


    @changed_post_thumbs.each do |post_thumb|

      if post_thumb.arbitrary[:update]

        post_thumb.node.save!
        #handle_after_update_post_node(post_thumb)

      elsif post_thumb.arbitrary[:create]
        post_thumb.post_id = @post.id
        post_thumb.save!
        #handle_after_create_post_node(post_thumb)

      end

    end

    validate_post_nodes_length

    validate_post_thumbs_length

    update_post_post_order(@changed_post_nodes)

    persist_s_nodes(@changed_post_nodes)

    prepare_post_tags(@post_tags_attributes)

    if @post.changed?
      @post.updater.update_tsv!
    end

    @post.save!



  end




  def remove_destroyed_items_from(relation)
    relation.delete_if do |node|
      node.arbitrary[:_should_destroy]
    end
  end



  def validate_post_nodes_length
    if @changed_post_nodes.length < 1
      @post.add_custom_error(:general, 'at least one node shall be provided')
    end
  end






  def validate_post_thumbs_length
    if @changed_post_thumbs.length < 1 || @changed_post_nodes.length > 2
      @post.add_custom_error(:general, "post thumbs should not be less then 1 nor greater than 2")
    end
  end




  def update_post_post_order(post_nodes)

    @post.nodes_order = post_nodes.map(&:id)
  end



  def persist_s_nodes(post_nodes)
    @post.updater.build_and_persist_s_nodes(post_nodes)
  end



  def prepare_post_tags(post_tags_attributes)
    @post.updater.update_post_tags(post_tags_attributes)
  end



  def handle_after_update_post_node(post_node)
    post_node.updater.try_update_tsv!
  end



  def handle_after_create_post_node(post_node)
    post_node.updater.try_update_tsv!
  end



  def handle_after_destroy_post_node(post_node)
    post_node.updater.try_destroy_tsv!
  end



  def update_post_tsv(node)

  end



  def resolve_success
    publish(:ok, @post)
  end



  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post, @changed_post_nodes, @changed_post_thumbs)
    else
      raise e
    end
  end

end
