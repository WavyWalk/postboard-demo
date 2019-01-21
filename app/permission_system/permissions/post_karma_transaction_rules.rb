class Permissions::PostKarmaTransactionRules < Permissions::Base

  def create
    @current_user
  end

end
