class CsvImportTemplatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_is_admin

  def index
    @templates = CsvImportTemplate.order('created_at DESC')
  end

  def new
    @template = CsvImportTemplate.new
  end

  def create
    @template = CsvImportTemplate.new(params[:template])
    @template.user = current_user
    if @template.save
      flash[:notice] = 'Template created successfully'
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def show
    @template = CsvImportTemplate.find(params[:id])
  end

  def edit
    @template = CsvImportTemplate.find(params[:id])
  end

  def update
    @template = CsvImportTemplate.find(params[:id])
    if @template.update_attributes(params[:template])
      flash[:notice] = 'Template updated successfully'
      redirect_to(:action => 'show', :id => @template.id)
    else
      render('edit')
    end
  end

  def destroy
    template = CsvImportTemplate.find(params[:id])
    template.template_file = nil
    template.destroy
    flash[:notice] = 'Template destroyed successfully'
    redirect_to(:action => 'index')
  end
end
