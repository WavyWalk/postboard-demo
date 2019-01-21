class ComposerFor::PostGifs::AddSubtitles < ComposerFor::Base

  def initialize(params, controller)
    @unpermitted_params = params
    @controller = controller
  end

  def before_compose
    set_permitted_attributes
    find_and_set_post_gif!
    assign_attributes
    validate_post_gif
  end


  def set_permitted_attributes
    @permitted_attributes = @unpermitted_params.require('post_gif').permit('id', 'subtitles')
  end

  def find_and_set_post_gif!
    @post_gif = PostGif.find(@permitted_attributes['id'])
  end

  def assign_attributes
    #validator will filter unneded keys, so if keys are gone unexpectedly chek there
    @post_gif.subtitles = @permitted_attributes['subtitles']
  end

  def validate_post_gif
    @post_gif.validation_service.set_scenarios(:when_subtitles_added).validate
  end

  def compose
    @post_gif.save!
  end

  def resolve_success
    publish(:ok, @post_gif)
  end

  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_gif)
    else
      raise e
    end

  end

end
