class Notification < ActiveRecord::Base
  belongs_to :user

  WELCOME_TEXT = %Q{

    <h1>I'm really glad to see you here!</h1>
    <p>enjoy the demo</p>
  
  }


  def self.qo
    ::ModelQuerier::Notification.new
  end

  def self.send_welcome_message(user_id)
    Notification.create(content: Notification::WELCOME_TEXT, user_id: user_id)
  end


end
