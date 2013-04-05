# Non-restful controller for handling data uploads

class UploadController < ApplicationController
  before_filter :authenticate_user!

  def index
    # show the uploaded datasets
    @datasets = CsvDataset.order('created_at DESC')
    @dataset = CsvDataset.new # For new upload
  end

  def create
    @dataset = CsvDataset.new(params[:dataset])
    @dataset.user = current_user
    if @dataset.save
      flash[:notice] = "#{@dataset.csv_file_file_name} has been uploaded"
      flash[:alert] = nil
      @dataset.create_import_job
      redirect_to :controller => 'after_upload', :import_job_id => @dataset.import_job.id
    else
      render('index')
    end
  end

  # Occurs after file is uploaded.  Reads the CSV headers and presents them for selection
  # If the file is not a CSV, it will be caught here
  def select_headers
    dataset = CsvDataset.find(params[:id])
    unless dataset.import_job
      dataset.create_import_job
    end
    @import_job = dataset.import_job
    @import_job.read_headers
    @import_job.count_rows
    if @import_job.failed?
      flash[:notice] = nil
      flash[:alert] = 'Unable to read CSV headers, please make sure you have uploaded a valid CSV file.'
    end
  end

  # The rest of the steps are not performed on-demand.
  # They are delayed with delayed_job
  # These will be good to use ajax

  # Receives POST from select_headers
  def start_validation
    @import_job = CsvDataset.find(params[:id]).import_job
    if @import_job.nil?
      redirect_to(:action => 'select_headers', :id => params[:id])
      return
    end

    unless @import_job.update_attributes(params[:import_job])
      render('select_headers')
      return
    end

    # Validate the headers of the dataset
    # if validation is already in progress, return such info
    if @import_job.running?
      flash[:notice] = "#{@import_job.file_name} is being validated, please reload to check status"
      flash[:alert] = nil
      redirect_to(:action => 'validating', :id => @import_job.csv_dataset.id)
    elsif @import_job.failed?
      # if validation failed, show message
      flash[:alert] = "#{@import_job.file_name} failed to validate, please review the errors below"
      flash[:notice] = nil
      render('select_headers')
    elsif @import_job.validated_headers?
      flash[:notice] = nil
      flash[:alert] = nil
      redirect_to(:action => 'check_rows', :id => params[:id])
    else
      flash[:notice] = "#{@import_job.file_name} is being validated, please reload to check status"
      flash[:alert] = nil
      @import_job.delay.do_validation
      redirect_to(:action => 'validating', :id => @import_job.csv_dataset.id)
    end
  end

  # should only be GET, shows status of validation
  def validating
    @import_job = CsvDataset.find(params[:id]).import_job
    if @import_job.nil?
      redirect_to(:action => 'select_headers', :id => params[:id])
      return
    end

    # Validate the headers of the dataset
    # if validation is already in progress, return such info
    if @import_job.validated_headers?
      redirect_to(:action => 'check_rows', :id => params[:id])
    elsif @import_job.running?
      flash[:notice] = "#{@import_job.file_name} is being validated, please reload to check status"
      flash[:alert] = nil
    elsif @import_job.failed?
      # if validation failed, show message
      flash[:alert] = "#{@import_job.file_name} failed to validate, please review the errors below"
      flash[:notice] = nil
    else
      flash[:notice] = "#{@import_job.file_name} is being validated, please reload to check status"
      flash[:alert] = nil
    end
  end

  #
  def check_rows
    @import_job = CsvDataset.find(params[:id]).import_job
    if @import_job.nil?
      redirect_to(:action => 'select_headers', :id => params[:id])
      return
    end

    if @import_job.parsed_rows?
      if @import_job.parse_warnings?
        flash[:alert] = "Some rows in #{@import_job.file_name} cannot be imported, please review the warnings"
        flash[:notice] = nil
      else
        flash[:alert] = nil
        flash[:notice] = nil
        redirect_to(:action => :import_rows)
      end
    elsif @import_job.running?
      flash[:notice] = "#{@import_job.file_name} is being parsed, please reload to check status"
      flash[:alert] = nil
    elsif @import_job.failed?
      # if validation failed, show message
      flash[:alert] = "#{@import_job.file_name} cannot be imported, please review the errors below"
      flash[:notice] = nil
    elsif @import_job.parse_warnings?
      flash[:notice] = nil
      flash[:alert] = nil
    else
      flash[:notice] = "#{@import_job.file_name} is being parsed, please reload to check status"
      @import_job.delay.do_parse
    end
  end

  def import_rows
    @import_job = CsvDataset.find(params[:id]).import_job
    if @import_job.nil?
      redirect_to(:action => 'select_headers', :id => params[:id])
      return
    end

    if @import_job.imported?
      flash[:notice] = "The file #{@import_job.file_name} has been successfully imported"
      flash[:alert] = nil
      redirect_to(:action => 'index')
    elsif @import_job.running?
      flash[:notice] = "#{@import_job.file_name} is being imported, please reload to check status"
      flash[:alert] = nil
    elsif @import_job.failed?
      # if validation failed, show message
      flash[:alert] = "#{@import_job.file_name} cannot be imported, please review the errors below."
      flash[:notice] = nil
    else
      @import_job.delay.do_import
    end
  end

  def delete
    @dataset = CsvDataset.find(params[:id])
  end

  def destroy
    dataset = CsvDataset.find(params[:id])
    filename = dataset.csv_file_file_name
    if dataset.destroy
      flash[:notice] = "#{filename} has been deleted"
    end
    redirect_to(:action => 'index')
  end

  def show
    @dataset = CsvDataset.find(params[:id])
  end

  def new
    @dataset = CsvDataset.new
  end


end
