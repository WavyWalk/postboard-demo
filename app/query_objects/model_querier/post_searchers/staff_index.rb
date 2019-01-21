class ModelQuerier::PostSearchers::StaffIndex

  attr_accessor :params

  def initialize(params, pagination_settings)

    @params = params

    @pagination_settings = pagination_settings

    set_conditionals

    build_query_object

  end

  def set_conditionals

    unless params[:post][:title].blank?
      @title = params[:post][:title]
    end

    unless params[:post][:fulltext].blank?
      @fulltext_query = params[:post][:fulltext]
    end

    if params[:post][:published] == '1'
      @published = true
    end

    if params[:post][:unpublished] == '1'
      @unpublished = true
    end

    unless params[:post][:by_user_name].blank?
      @by_user_name = params[:post][:by_user_name]
    end

    @order = params[:post][:order] ? params[:post][:order] : 'DESC'
  end

  def build_query_object

    qo = Post.qo_service

    if @title
      qo.where_title_like(@title)
    end

    if @published && @unpublished
      nil
    else
      if @published
        qo.is_published
      end

      if @unpublished
        qo.is_unpublished
      end
    end

    if @by_user_name
      qo.join_author_user_credential.where_author_name_like(@by_user_name)
    end

    if @fulltext_query
      qo.search_full_text(@fulltext_query)
    else
      qo.order_by_created_at
    end

    qo.standart_includes

    @qo = qo.get_relation.paginate(@pagination_settings)

  end

  def get_relation
    @qo
  end

end
