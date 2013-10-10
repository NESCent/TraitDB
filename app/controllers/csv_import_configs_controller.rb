class CsvImportConfigsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_is_admin, :except => [:index, :show]

  before_filter :set_project

  def index
    @configs = @project.csv_import_configs.order('created_at DESC')
  end

  def new
    @config = CsvImportConfig.new
  end

  def create
    @config = CsvImportConfig.new(params[:config])
    @config.project = @project
    @config.user = current_user
    if @config.save
      @config.update_name
      @config.save
      flash[:notice] = 'Config created successfully'
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def show
    @config = @project.csv_import_configs.find(params[:id])
  end

  def edit
    @config = @project.csv_import_configs.find(params[:id])
  end

  def update
    @config = @project.csv_import_configs.find(params[:id])
    if @config.update_attributes(params[:config])
      flash[:notice] = 'Config updated successfully'
      redirect_to(:action => 'show', :id => @config.id)
    else
      render('edit')
    end
  end

  def destroy
    config = @project.csv_import_configs.find(params[:id])
    config.config_file = nil
    config.destroy
    flash[:notice] = 'Config destroyed successfully'
    redirect_to(:action => 'index')
  end
end
