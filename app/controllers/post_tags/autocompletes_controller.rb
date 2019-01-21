class PostTags::AutocompletesController < ApplicationController


  def index
    
    if !params[:typed].blank?  
      post_tags = PostTag.qo_service.where_name_like(params[:typed].mb_chars.downcase.to_s)
    else
      post_tags = []
    end

    render json: AsJsonSerializer::PostTags::Autocompletes::Index.new(post_tags).success

  end


end
