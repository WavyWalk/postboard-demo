class PostGifsController < ApplicationController

  def create

    build_permissions PostGif

    authorize! @permission_rules

    cmpsr = ComposerFor::PostGifs::Create.new(PostGif.new, params, self)

    cmpsr.when(:ok) do |post_gif|
     render json: AsJsonSerializer::PostGif::Create.new(post_gif).success
    end

    cmpsr.when(:validation_error) do |post_gif|
     render json: AsJsonSerializer::PostGif::Create.new(post_gif).error
    end

    cmpsr.run

  end

  def add_subtitles

    build_permissions PostGif

    authorize! @permission_rules.add_subtitles(params['post_gif']['id'])

    cmpsr = ComposerFor::PostGifs::AddSubtitles.new(params, self)

    cmpsr.when(:ok) do |post_gif|
      render json: AsJsonSerializer::PostGif::Create.new(post_gif).success
    end

    cmpsr.when(:validation_error) do |post_gif|
      render json: AsJsonSerializer::PostGif::Create.new(post_gif).error
    end

    cmpsr.run

  end

end
