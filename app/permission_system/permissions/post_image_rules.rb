class Permissions::PostImageRules < Permissions::Base

  def create
    if @current_user
      true
    else
      false
    end
  end

end
