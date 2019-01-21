class ComposerFor::Users::Avatars::Update < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    permit_attributes
    set_user
    assign_attributes
    #validate
  end

  def permit_attributes
    @permitted_attributes = @params.require('user').permit('avatar')
  end

  def set_user
    @user = User.find(@params['user_id'])
  end

  def assign_attributes
    @user.avatar = @permitted_attributes['avatar']
  end

  def compose
    @user.save!
    serialize_s_avatar
  end

  def serialize_s_avatar
    @user.updater.serialize_avatar_to_s_avatar_and_save!
  end

  def resolve_success
    publish(:ok, @user)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @user)
    else
      raise e
    end

  end

end
