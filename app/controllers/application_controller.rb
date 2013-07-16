class ApplicationController < ActionController::Base
  protect_from_forgery

  def verify_is_admin
    if current_user.nil? || !current_user.admin?
      redirect_to root_path
      false
    end
  end

  def set_project
    if session[:current_project]
      @project = Project.find(session[:current_project])
    else
      redirect_to({:controller => 'projects', :action => 'select_project' })
      false
    end
  end
end
