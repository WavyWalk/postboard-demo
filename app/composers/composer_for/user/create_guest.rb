class ComposerFor::User::CreateGuest < ComposerFor::Base

  def initialize(model, controller)
    @model = model
    @controller = controller
  end


  def before_compose
    build_user
    build_user_credential
    build_user_karma
    build_user_denormalized_stat
    assign_guest_role
  end


  def build_user
    @model.registered = false
  end


  def build_user_credential
    @model.user_credential = UserCredential.new
  end


  def build_user_karma
    @model.user_karma = UserKarma.new(count: 0)
  end

  def build_user_denormalized_stat
    @model.user_denormalized_stat = UserDenormalizedStat.new
  end


  def assign_guest_role
 
    @model.role_service.add_role('guest', 'no_name', 'no_email', 'no_e_or_p')

  end


  def compose
    @model.save!
  end


  def after_compose
    login_and_remember_user
    create_welcome_notification
  end


  def login_and_remember_user
    @controller.log_in @model
    @controller.remember @model
  end


  def create_welcome_notification
    Notification.send_welcome_message(@model.id)
  end


  def resolve_success
    publish :ok, @model
  end


  def resolve_fail(e)

    case e
    when ActiveRecord::RecordInvalid
      raise e
    else
      raise e
    end

  end

end
