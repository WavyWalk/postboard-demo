class ComposerFor::Posts::Create < ComposerFor::Base

  def initialize(model, params, controller = false, options = {})
    @model = model
    @params = params
    @controller = controller
    @options = options
  end

  def before_compose

    permit_attributes

    prepare_and_check_post_nodes

    concatenate_text_nodes_if_they_are_sequent_and_remove_unnecessary

    assign_author_id_to_model

    assign_title_to_post

    build_new_discussion_for_post

    build_new_post_karma_for_post

    build_post_tags

    build_post_type

    validate_post

  end

  def permit_attributes
    @permitted_attributes = @params.require(:post)
                                  .permit(
                                            :title,
                                            {
                                              post_tags: [
                                                :name
                                              ]
                                            },
                                            {
                                              post_nodes: [
                                                {node:
                                                  [
                                                    :id, :content, :link
                                                  ]
                                                },
                                                :node_type
                                              ]
                                            },
                                            {
                                              post_thumbs: [
                                                {
                                                  node:
                                                  [
                                                    :id, :content, :link
                                                  ],
                                                },
                                                :node_type
                                              ]
                                            },
                                            {
                                              post_type: [
                                                :id
                                              ]
                                            }
                                          )
  end

  # GROUP
  def prepare_and_check_post_nodes
    @post_nodes_hash = @permitted_attributes[:post_nodes] || []
    build_post_nodes_to_persist
  end

  def build_post_nodes_to_persist
    @post_nodes_hash.each do |post_node|
      @model.post_nodes << (
        #beware - validates there
        PostNode.factory.initialize_with_node_when_creating_post(post_node)
      )
    end

  end
  # GROUP END

  def concatenate_text_nodes_if_they_are_sequent_and_remove_unnecessary

    @model.updater.concat_repeating_post_text_nodes_content_and_remove_unnecessary

  end

  # relying on validates associated
  # def validate_post_nodes
  #   @model.post_nodes.each do |post_node|
  #     post_node.node.validation_service.set_scenarios(:when_post_create).validate
  #   end
  # end


  def assign_author_id_to_model

    @model.author_id = @controller.current_user.id

  end



  def assign_title_to_post
    @model.title = @permitted_attributes[:title]
  end


  def build_new_discussion_for_post
    @model.discussion = Discussion.new
  end




  def build_new_post_karma_for_post
    @model.post_karma = PostKarma.new(count: 0)
  end




  def build_post_tags

    post_tags = PostTag.factory.create_collection_for_post_create( @permitted_attributes[:post_tags] )
    @model.post_tags = post_tags

  end


  def build_post_type
    if x = @permitted_attributes[:post_type]
      post_type = PostType.find( x[:id] )
      @model.post_type = post_type
    end
  end


  def validate_post
    @model.validation_service.set_scenarios(:create).validate
  end


  def compose

    @model.save!

    #update_post_nodes_if_necessary TODO: should unorphan nodes that are

    handle_post_thumbs!

    populate_and_persist_nodes_order!

    persist_s_nodes

    @model.composer_helper.persist_tsvs_for_create

    add_karma_to_author_for_post_creation

  end





  def populate_and_persist_nodes_order!
    @model.updater.build_and_persist_nodes_order!
  end



  def persist_s_nodes
    @model.updater.build_and_persist_s_nodes
  end






  def add_karma_to_author_for_post_creation

    karma = @controller.current_user.user_karma
    karma.updater.add_for_post_creation
    karma.save!

    ::Services::DayKarmaEvent::Factory.record_when_user_created_post(
      user_id: @model.author_id,
      post_id: @model.id,
      source_text: @model.title
    )    
  end







  def handle_post_thumbs!
    @model.composer_helper.build_and_persist_post_thumbs_for_post_create!(@permitted_attributes[:post_thumbs])
  end



  def resolve_success
    publish(:ok, @model)
  end






  def resolve_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @model)
    when :post_node_from_client_is_empty_or_not_provided
      publish(:post_node_from_client_is_empty_or_not_provided, @model)
    when :unknown_node_provided_from_client
      raise 'unknow node provided'
    else
      raise e
    end

  end

end
