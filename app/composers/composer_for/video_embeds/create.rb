class ComposerFor::VideoEmbeds::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    assign_attributes
  end

  def permit_attributes
    @permitted_attributes = @params.require('video_embed')
      .permit(
        'link'
      )
  end

  def assign_attributes
    @video_embed = ::VideoEmbed.new
    @video_embed.link = @permitted_attributes['link']
    @video_embed.updater.assign_provider_depending_on_link
  end

  def validate
    @video_embed
      .validation_service
      .set_scenarios(:create)
      .validate
  end

  def compose
    @video_embed.save!
  end

  def resolve_success
    publish(:ok, @video_embed)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish :validation_error, @video_embed
    else
      raise e
    end

  end

end
