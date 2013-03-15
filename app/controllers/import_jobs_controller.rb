class ImportJobsController < ApplicationController
  # A Job to import a dataset
  # nested within CsvDataset?
  before_filter :authenticate_user!
  before_filter :find_dataset
  
  # add a method to run the import
  def index
    @import_jobs = @dataset.import_jobs.order('created_at DESC')
  end

  def new
    @import_job = ImportJob.new(:csv_dataset => @dataset)
  end

  def create
    @import_job = ImportJob.new(params[:import_job])
    @import_job.csv_dataset = @dataset
    if @import_job.save
      flash[:notice] = 'Import Job created successsfully'
      # start the import
      redirect_to(csv_dataset_import_jobs_path(@dataset))
    else
      render('new')
    end
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

  # uses delayed job
  def background_import
    import_job = ImportJob.find(params[:id])
    import_job.delay.do_import
    flash[:notice] = 'Import started'
    redirect_to(csv_dataset_import_job_path(@dataset, import_job))
  end

  # Does not use delayed job
  def import
    import_job = ImportJob.find(params[:id])
    if import_job.do_import
      flash[:notice] = 'Import Succeeded'
    else
      flash[:notice] = 'Import Failed'
    end
    redirect_to(csv_dataset_import_job_path(@dataset, import_job))
  end

  def validate
    import_job = ImportJob.find(params[:id])
    import_job.do_validation
    redirect_to(csv_dataset_import_job_path(@dataset, import_job))
  end

  def reset_job
    import_job = ImportJob.find(params[:id])
    import_job.reset
    redirect_to(csv_dataset_import_job_path(@dataset, import_job))
  end

  private
  
  def find_dataset
    @dataset = CsvDataset.find(params[:csv_dataset_id])
  end
  
end
