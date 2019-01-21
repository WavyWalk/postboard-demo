class UserMailer < ApplicationMailer

  def account_activation_email(user, login_token)
    
    @user = user
    @user_credential = user.user_credential

    @activation_string = login_token

    mail(to: @user_credential.email, subject: 'estzhe welcomes you!')

  end

  def login_link_email(user, link_token)
    
    @user = user
    @login_link = link_token
    
    mail(to: @user.user_credential.email, subject: 'estzhe wants you to login!')  
  end

end
