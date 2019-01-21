class ApplicationController < ActionController::Base

  #PERMISSION SYSTEM

  #skip_before_filter :verify_authenticity_token

  include Permissions::ControllerMethods
  include SessionsHelper



  rescue_from Permissions::Exception, with: :user_not_authorized

  def user_not_authorized
    head 403
  end

  def pagination_service
    Services::Pagination
  end

  #END PERMISSION SYSTEM
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


end
