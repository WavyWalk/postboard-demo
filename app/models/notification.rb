class Notification < ActiveRecord::Base
  belongs_to :user

  WELCOME_TEXT = %Q{

    <h1>You know what? We're really glad to see you here!</h1>
    <p>You don't need registration, and you can participate in most of the awesome shit we've prepared for you right away.</p>
    <p>Try on - upvote or downvote some post or comment of someone you hate!</p>    
    <p>If you want to be even cooler and live dangerously - you can register. It's super easy - just leave your name (fun stuff preferred).</p>    
    <p><b>AAAAND BOOM</b>, you can post your posts in posts feed (exibit.jpg), or leave a sharp witty comment as you always do!11</p>
    <h1>How awesome is that?</h1>    
    <p>In case you want to login next time, or enter from another device leave either password or email there - and receive 1000 karma.</p>   
    <p>We promise to respect your personal data and won't give it away!</p> 
    <h1>Loving you!</h1>
  
  }


  def self.qo
    ::ModelQuerier::Notification.new
  end

  def self.send_welcome_message(user_id)
    Notification.create(content: Notification::WELCOME_TEXT, user_id: user_id)
  end


end
