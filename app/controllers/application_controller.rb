class ApplicationController < ActionController::Base
  protect_from_forgery

  def verify_is_admin
    if current_user.nil? || !current_user.admin?
      redirect_to root_path
      false
    end
  end

  def verify_project_selected
    unless session[:current_project]
      redirect_to({:controller => 'projects', :action => 'select_project' })
      false
    end
  end
end
