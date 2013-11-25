class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_projects

  def verify_is_admin
    if current_user.nil? || !current_user.admin?
      redirect_to root_path
      false
    end
  end

  def set_project
    if @project
      return true
    end
    if session[:current_project_id]
      @project = Project.find(session[:current_project_id])
    else
      redirect_to({:controller => 'projects', :action => 'select_project' })
      false
    end
  end

  private

  def set_projects
    @selectable_projects = Project.sorted
  end
end
