class PostTypesController < ApplicationController

  def feed

    types = PostType.qo.get_all_types
    render json: PostType.as_json_serializer::Feed.new(types).success

  end

end
