class HomeController < ApplicationController

  #refer to #persist_huest for details
  

  def index
    
    unless logged_in?

      cmpsr = ComposerFor::User::CreateGuest
        .new(User.new, self)
        
    

      cmpsr.when(:ok) do |user|
        #data is passed to front end and will be serialized there
        @data = {
          current_user: user.as_json(only: [:id, :registered], include: [{user_roles: {only: 'name'}}, {user_karma: {only: ["count", 'id']}}, {user_credential: {only: 'name'}}])
        }.to_json
      
      end

      cmpsr.run

    else

      @data = {
        current_user: current_user.as_json(only: [:id, :registered], include: [{user_roles: {only: 'name'}}, {user_karma: {only: ["count", 'id']}}, {user_credential: {only: 'name'}}])
      }.to_json

    end

  end

  def console
    raise "hello there!"
  end


end
