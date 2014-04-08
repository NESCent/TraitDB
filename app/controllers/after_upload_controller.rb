# Controller for stepping through import process after upload
class AfterUploadController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!
  before_filter :set_project
  steps :read_headers, :count_rows, :select_config, :validate_headers, :parse_rows, :import_rows, :imported
  # Works off an import job?
  def show
    @import_job = ImportJob.find(params[:import_job_id])
    # if job is running, stay on the current step
    if @import_job.running?
      @status = 'running'
      render_wizard
      return
    end

    # if job is failed, show the errors
    handle_step
    render_wizard
  end

  def update
    @import_job = ImportJob.find(params[:import_job_id])
    @import_job.update_attributes(params[:import_job])
    handle_step
    render_wizard
  end

  def delete
    import_job = ImportJob.find(params[:import_job_id])
    dataset = CsvDataset.find(params[:id])
    filename = dataset.csv_file_file_name

    dataset.csv_file = nil
    dataset.destroy
    import_job.destroy
    flash[:notice] = "#{filename} has been deleted."
    redirect_to(:controller => 'upload', :action => 'index')
  end

  # Download the rows from this dataset that cannot be imported as a csv
  def download_problematic_rows
    import_job = ImportJob.find(params[:import_job_id])
    @output_csv_string = import_job.problem_rows_csv_string
    respond_to do |format|
      format.csv do
        filename = "#{File.basename(import_job.file_name, '.csv')}-problematic_rows-#{Time.now.strftime("%Y%m%d")}.csv"
        if request.env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers["Content-type"] = "text/plain"
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
          headers['Expires'] = "0"
        else
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
        end
      end
    end
  end

  # Download the parse issues as a CSV file
  def download_issues
    import_job = ImportJob.find(params[:import_job_id])
    @output_csv_string = import_job.download_issues_csv_string
    respond_to do |format|
      format.csv do
        filename = "#{File.basename(import_job.file_name, '.csv')}-import_issues_report-#{Time.now.strftime("%Y%m%d")}.csv"
        if request.env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers["Content-type"] = "text/plain"
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
          headers['Expires'] = "0"
        else
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
        end
      end
    end
  end

  private

  def handle_step
    case step
      when :read_headers
        if @import_job.read_headers?
          skip_step
        else
          # Read the headers
          @import_job.read_headers
        end
      when :count_rows
        if @import_job.counted_rows?
          skip_step
        else
          @import_job.count_rows
        end
      when :select_config
        if @import_job.csv_import_config
          skip_step
        end
      when :validate_headers
        if @import_job.parsed_rows?
          skip_step
        else
          unless @import_job.validated_headers?
            @import_job.delay.do_validation unless @import_job.running? || @import_job.failed?
          end
        end
      when :parse_rows
        if @import_job.imported?
          skip_step
        else
          unless @import_job.parsed_rows?
            @import_job.delay.do_parse unless @import_job.running? || @import_job.failed?
          end
        end
      when :import_rows
        if @import_job.imported?
          skip_step
        else
          @import_job.delay.do_import unless @import_job.running? || @import_job.failed?
        end
    end
  end
end
