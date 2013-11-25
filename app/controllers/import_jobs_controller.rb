class ImportJobsController < ApplicationController
  # A Job to import a dataset
  # nested within CsvDataset?
  # Mostly obsolete
  before_filter :authenticate_user!
  before_filter :verify_is_admin
  before_filter :set_project
  before_filter :find_dataset
  
  # add a method to run the import
  def index
    @import_jobs = [@dataset.import_job]
  end

  def show
    @import_job = ImportJob.find(params[:id])
  end
  
  def edit
    @import_job = ImportJob.find(params[:id])
  end

  def update
    @import_job = ImportJob.find(params[:id])
    if @import_job.update_attributes(params[:import_job])
      flash[:notice] = 'Job updated successfully'
      redirect_to(csv_dataset_import_job_path(@dataset, @import_job))
    else
      render('edit')
    end
  end

  def destroy
    import_job = ImportJob.find(params[:id])
    import_job.destroy
    flash[:notice] = 'Job destroyed successfully'
    redirect_to(csv_dataset_import_jobs_path(@dataset))
  end

  private
  
  def find_dataset
    @dataset = @project.csv_datasets.find(params[:csv_dataset_id])
  end
  
end
