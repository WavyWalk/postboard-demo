class VideoEmbedsController < ApplicationController

  def create
    permission_rules = build_permissions VideoEmbed
    authorize! permission_rules.create

    cmpsr = ComposerFor::VideoEmbeds::Create.new(params, self)

    cmpsr.when(:ok) do |video_embed|
      render json: AsJsonSerializer::VideoEmbed::Create.new(video_embed).success
    end

    cmpsr.when(:validation_error) do |video_embed|
      render json: AsJsonSerializer::VideoEmbed::Create.new(video_embed).error
    end

    cmpsr.run

  end

end
