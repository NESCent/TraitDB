# Controller for stepping through import process after upload
class AfterUploadController < Wicked::WizardController
  before_filter :authenticate_user!
  before_filter :verify_is_admin

  steps :read_headers, :count_rows, :select_trait_headers, :validate_headers, :parse_rows, :import_rows, :imported

  def index
    show
  end

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

  def download_problematic_rows

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
      when :select_trait_headers
        if @import_job.selected_trait_headers?
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
