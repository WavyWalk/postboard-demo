class PostImagesController < ApplicationController

  def create

    build_permissions PostImage

    authorize! @permission_rules

    cmpsr  = ComposerFor::PostImage::Create.new(PostImage.new, params, self)

    cmpsr.when(:ok) do |post_image|
      render json: AsJsonSerializer::PostImage::Create.new(post_image).success
    end

    cmpsr.when(:validation_error) do |post_image|
      render json: AsJsonSerializer::PostImage::Create.new(post_image).error
    end

    cmpsr.run

  end

  def create_from_url

    build_permissions PostImage

    authorize! @permission_rules.create

    cmpsr = ComposerFor::PostImages::CreateFromUrl.new(self, params)

    cmpsr.when(:ok) do |proxy_image|
      render json: AsJsonSerializer::PostImage::Create.new(proxy_image).success
    end

    cmpsr.when(:validation_error) do |proxy_image|
      render json: AsJsonSerializer::PostImage::Create.new(proxy_image).error
    end

    cmpsr.run

  end

end
