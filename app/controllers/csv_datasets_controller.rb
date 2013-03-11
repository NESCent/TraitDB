class CsvDatasetsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @datasets = CsvDataset.order('created_at DESC')
  end

  def new
    @dataset = CsvDataset.new
  end

  def create
    @dataset = CsvDataset.new(params[:dataset])
    #@dataset.project = Project.first
    @dataset.user = current_user
    if @dataset.save
      flash[:notice] = 'Dataset created successsfully'
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def show
    @dataset = CsvDataset.find(params[:id])
  end
  
  def edit
    @dataset = CsvDataset.find(params[:id])
  end

  def update
    @dataset = CsvDataset.find(params[:id])
    if @dataset.update_attributes(params[:dataset])
      flash[:notice] = 'Dataset updated successfully'
      redirect_to(:action => 'show', :id => @dataset.id)
    else
      render('edit')
    end
  end

  def destroy
    # accepts the delete form
    dataset = CsvDataset.find(params[:id])
    dataset.csv_file = nil
    dataset.destroy
    flash[:notice] = 'Dataset destroyed successfully'
    redirect_to(:action => 'index')
  end

  
end
