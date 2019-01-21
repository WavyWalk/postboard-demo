class Permissions::VotePollTransactionRules < Permissions::Base

  def create
    if @current_user
      true
    end
  end

end 
