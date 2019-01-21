class ComposerFor::Staff::Posts::Create < ComposerFor::Base




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

    sanitize_content_of_post_texts

    validate_post_nodes

    assign_author_id_to_model
    assign_title_to_post

    validate_post

    buld_and_assign_final_post_nodes
    build_new_discussion_for_post
    build_new_post_karma_for_post

    build_post_tags

  end





  def permit_attributes
    @permitted_attributes = @params.require(:post)
                                  .permit(
                                            :title, post_tags: [:name], post_nodes: [{post_image: [:id]},
                                            {post_text: [:id, :content]}, {post_gif: [:id]}]
                                          )
  end





  #POSTNODES PREPARATION
  def prepare_and_check_post_nodes
    assign_post_nodes_shortcut
    validate_post_nodes_to_be_not_empty!
    build_post_nodes_to_persist
  end



  #shortcut for nodes array on params
  def assign_post_nodes_shortcut
    @post_nodes = @permitted_attributes[:post_nodes]
  end




  def validate_post_nodes_to_be_not_empty!
    if !@post_nodes.is_a?(Array) || @post_nodes.length < 1
      fail_immediately(:post_node_from_client_is_empty_or_not_provided)
    end
  end




  #NODES ARRAY BUILDING
  def build_post_nodes_to_persist
    @post_nodes_to_persist_pre_final_array = []
    @post_nodes.each do |post_node|
      model_type, attributes = post_node.to_a[0]
      build_node_depending_on_model_type(model_type, attributes)
    end
  end
  #END POSTNODES PREPARATION








  def build_node_depending_on_model_type(model_type, attributes)
    case model_type
    when 'post_text'
      build_post_text(attributes)
    when 'post_image'
      find_and_prepare_post_image!(attributes)
    when 'post_gif'
      find_and_prepare_post_gif(attributes)
    else
      fail_immediately(:unknown_node_provided_from_client)
    end
  end







  def build_post_text(attributes)

    post_text = ::PostText.new(attributes)

    @post_nodes_to_persist_pre_final_array << post_text

  end








  def find_and_prepare_post_image!(attributes)

    post_image = ::PostImage.where(id: attributes[:id]).first

    if post_image
      post_image.orphaned = false
      post_image.save
      @post_nodes_to_persist_pre_final_array << post_image
    else
      post_image = ::PostImage.new
      post_image.add_custom_error(:general, 'such image could not be found try uploading new')
      @post_nodes_to_persist_pre_final_array << post_image
    end

  end








  def find_and_prepare_post_gif(attributes)
    post_gif = ::PostGif.where(id: attributes[:id]).first

    if post_gif
      post_gif.orphaned = false
      post_gif.save
      @post_nodes_to_persist_pre_final_array << post_gif
    else
      post_gif = ::PostGif.new
      post_gif.add_custom_error(:general, 'such gif coul not be found, try uploading new')
      @post_nodes_to_persist_pre_final_array << post_gif
    end

  end

  #END NODES ARRAY BUILDING
  def concatenate_text_nodes_if_they_are_sequent_and_remove_unnecessary

    @post_nodes_to_persist_pre_final_array.each_with_index do |elem, index|

      first = elem
      second = @post_nodes_to_persist_pre_final_array[index+1]

      if first.is_a?(PostText) && second.is_a?(PostText)

        text = first.content + second.content
        second.content = text
        first.content = nil

      end

    end

    @post_nodes_to_persist_pre_final_array.reject! do |node|
      node.is_a?(PostText) && node.content == nil
    end

  end


  def sanitize_content_of_post_texts
    @post_nodes.each do |node|
      if node.is_a?(PostText)
        node.content = Services::PostTextSanitizer.sanitize_post_text_content(node.content)
      end
    end
  end

  def validate_post_nodes
    @post_nodes_to_persist_pre_final_array.each do |node|
      validate_node_depending_on_type node
    end
  end


  def validate_node_depending_on_type(node)

    case node
    when PostText
      ModelValidator::PostText.new(node).set_scenarios(:create).validate
    when PostImage
      ModelValidator::PostImage.new(node).set_scenarios(:assignemnt_to_post_node).validate
    when PostGif
      ModelValidator::PostGif.new(node).set_scenarios(:assignemnt_to_post_node).validate
    end

  end







  def assign_author_id_to_model
    @model.author_id = @controller.current_user.id
  end






  def assign_title_to_post
    @model.title = @permitted_attributes[:title]
  end




  def validate_post
    @model.validation_service.set_scenarios(:create).validate
  end





  def buld_and_assign_final_post_nodes

    @final_post_nodes = []

    @post_nodes_to_persist_pre_final_array.each do |node|

      post_node = PostNode.new
      post_node.node = node

      @final_post_nodes << post_node

    end

    @model.post_nodes = @final_post_nodes

  end







  def build_new_discussion_for_post
    @model.discussion = Discussion.new
  end






  def build_new_post_karma_for_post
    @model.post_karma = PostKarma.new(count: 0)
  end








  def build_post_tags


    tag_names = @permitted_attributes[:post_tags].map do |pt|
      pt[:name].mb_chars.downcase.to_s.strip.squeeze(" ")
    end


    existing_post_tags = PostTag.where("name in (?)", tag_names)


    non_existent_post_tags = ( tag_names -= existing_post_tags.map(&:name) )


    new_post_tags = non_existent_post_tags.inject([]) do |accumulator, pt_name|

      post_tag = PostTag.new(name: pt_name)

      #WARNING: this will not render errors it will just remove invalid tags
      #it relies on client side validation, so only valid tags are expected to come through
      #if tag is invalid it means that user frauded POST request.
      post_tag_validator = post_tag.validation_service

      #validates with special scenario #staff_create_scenario which allows special tags
      post_tag_validator.set_scenarios(:staff_create).validate


      unless post_tag.has_custom_errors?
        accumulator << post_tag
      end

      accumulator

    end

    #ADDS EMPTY SPECIAL PostTag to excplicitly state that this post is created by staff
    staff_tag = PostTag.find_or_create_by(special: true, name: nil)

    existing_post_tags << staff_tag

    post_tags = ( existing_post_tags += new_post_tags )


    @model.post_tags = post_tags


  end







  def compose

    @model.save!
    populate_and_persist_nodes_order!
    initialize_and_persist_post_tsvs!

  end








  def populate_and_persist_nodes_order!
    ids = @model.post_nodes.map(&:id)
    @model.nodes_order = ids
    @model.save!
  end




  def initialize_and_persist_post_tsvs!
    @post_tsvs = []
    @post_tsvs << Services::PostTsv.initialize_post_tsv(model: @model, post_id: @model.id)
    @post_nodes_to_persist_pre_final_array.each do |node|
      if node.is_a? PostText
        @post_tsvs << Services::PostTsv.initialize_post_tsv(model: node, post_id: @model.id)
      end
    end

    @post_tsvs.each do |p_tsv|
      p_tsv.save!
    end
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
