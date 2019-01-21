class PostTests::ThumbnailsController < ApplicationController

  def update
    post_test_id = params[:post_test_id]

    post_test = PostTest.find(post_test_id)

    image_id = params.require(:post_image).permit(:id)['id']

    post_test.thumbnail_id = image_id
    post_test.save!

    post_image = PostImage.find(image_id)

    ::Services::Post::SNodesUpdater::PostTestsRelated.update_when_post_test_thumbnail_updated(post_test)

    render json: post_image.as_json

  end

end
