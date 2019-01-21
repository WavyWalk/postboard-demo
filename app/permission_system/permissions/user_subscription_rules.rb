class Permissions::UserSubscriptionRules < Permissions::Base

  def create
    if @current_user
      true
    else
      false
    end
  end




  def destroy
    if @current_user
      true
    else
      false
    end
  end

  def index_for_user
    @current_user ? true : false    
  end

end
