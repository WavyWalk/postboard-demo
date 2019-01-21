class ComposerFor::User::Create::BuildComposer


  def initialize(controller)
    @controller = controller
  end


  def create
    set_conditionals
    initialize_composer_depending_on_conditionals
  end


  def set_conditionals
    if @controller.current_user && @controller.current_user.registered == false
      @user_is_guest_already = true
    else
      @should_update_user = true
    end

  end


  def initialize_composer_depending_on_conditionals
    if @user_is_guest_already
      return initialize_transfer_from_guest_composer
    elsif @should_update_user
      return initialize_update_user_composer      
    else
      raise "unreacheable #{sefl.class.name}#initialize_composer_depending_on_conditionals"
      #initialize_from_scratch_composer
    end
  end


  # def initialize_from_scratch_composer
  #   ComposerFor::User::Create::FromScratch.new(
  #     model: ::User.new,
  #     params: @controller.params,
  #     controller: @controller
  #   )
  # end


  def initialize_update_user_composer
    ComposerFor::User::Update.new(
      current_user: @controller.current_user,
      params: @controller.params,
      controller: @controller
    )
  end



  def initialize_transfer_from_guest_composer
    #raise 'TransferFromGuest composer not implemented'
    ::ComposerFor::User::Create::TransferFromGuest.new(
      model: @controller.current_user,
      params: @controller.params,
      controller: @controller
    )

  end


end
