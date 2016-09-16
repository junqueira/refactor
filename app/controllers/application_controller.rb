class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_model

  def current_model
    if Model.count > 0 && !session[:model_id].nil?
      Model.find(session[:model_id])
    end
  end
end