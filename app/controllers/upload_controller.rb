# Non-restful controller for handling data uploads

class UploadController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_is_admin
  before_filter :set_project # populates @project and makes sure project has been selected

  def index
    # show the uploaded datasets
    @datasets = @project.csv_datasets.order('created_at DESC')
    @dataset = CsvDataset.new # For new upload
  end

  def create
    @dataset = CsvDataset.new(params[:dataset])
    @dataset.project = @project
    @dataset.user = current_user
    if @dataset.save
      flash[:notice] = "#{@dataset.csv_file_file_name} has been uploaded"
      flash[:alert] = nil
      @dataset.create_import_job
      redirect_to :controller => 'after_upload', :import_job_id => @dataset.import_job.id
    else
      @datasets = @project.csv_datasets.order('created_at DESC')
      render('index')
    end
  end


  def delete
    @dataset = @project.csv_datasets.find(params[:id])
  end

  def destroy
    dataset = @project.csv_datasets.find(params[:id])
    filename = dataset.csv_file_file_name
    if dataset.destroy
      flash[:notice] = "#{filename} has been deleted"
    end
    redirect_to(:action => 'index')
  end

  def show
    @dataset = @project.csv_datasets.find(params[:id])
  end

  def new
    @dataset = CsvDataset.new
  end

end
