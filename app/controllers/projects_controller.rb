class ProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:select_project, :selected_project]
  before_filter :verify_is_admin, :except => [:select_project, :selected_project, :show, :index]
  def index
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.update_attributes(params[:project])
    if @project.save
      flash[:notice] = "Project '#{@project.name}' updated successfully"
      redirect_to(:action => 'show', :id => @project.id)
    else
      render 'edit'
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = "Project '#{@project.name}' has been created"
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end

  def delete
    @project = Project.find(params[:id])
  end

  def destroy
    project = Project.find(params[:id])
    name = project.name
    if project.destroy
      flash[:error] = "Project '#{name}' has been deleted"
    end
    redirect_to :action => 'index'
  end

  def select_project
    render 'select_project'
  end

  def selected_project
    session[:current_project] = Project.where(:id => params[:id]).first
    redirect_to root_url
  end
end
