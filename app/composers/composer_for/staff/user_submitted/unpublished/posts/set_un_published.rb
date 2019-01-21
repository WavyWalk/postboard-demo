class ComposerFor::Staff::UserSubmitted::Unpublished::Posts::SetUnPublished < ComposerFor::Base

  def initialize(params:, controller:)
    @params = params
    @controller = controller
  end




  def before_compose

    extract_and_set_post_id_from_params

    find_and_set_post

    set_post_as_published

  end




  def extract_and_set_post_id_from_params
    @post_id = @params[:id]
  end




  def find_and_set_post

    @post = Post.find(@post_id)

  end




  def set_post_as_published
    @post.published = false
    @post.published_at = nil
  end




  def compose
    @post.save!
  end




  def resolve_success
    publish(:ok, @post)
  end




  def resolve_fail(e)

    case e
    when ActiveRecord::RecordNotFound
      raise e
    else
      raise e
    end

  end

end
