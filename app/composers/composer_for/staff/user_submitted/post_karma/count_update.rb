class ComposerFor::Staff::UserSubmitted::PostKarma::CountUpdate < ComposerFor::Base

  def initialize(params: , controller: )
    @params = params
    @controller = controller
  end

  def before_compose
    
    permit_attributes
    find_and_set_post_karma!
    assign_attributes

  end

  def permit_attributes
    @permitted_attributes = @params.require('post_karma').permit(
        'id', 'count'
      )
  end

  def find_and_set_post_karma!
    @post_karma = PostKarma.where(id: @permitted_attributes['id']).first
    unless @post_karma
      fail_immediately(:post_karma_not_found)
    end
  end

  def assign_attributes
    @post_karma.count = @permitted_attributes['count']
    @post_karma = ::Services::PostKarma::ComposerHelpers.refine_hot_since(@post_karma)
  end

  def compose
    @post_karma.save!
  end

  def resolve_success
    publish(:ok, @post_karma)
  end

  def resolve_fail(e)
    
    case e
    when :post_karma_not_found
      pk = PostKarma.new
      pk.errors.add(:count, message: "something went wrong") 
      publish(:not_found)
    else
      raise e
    end

  end

end
