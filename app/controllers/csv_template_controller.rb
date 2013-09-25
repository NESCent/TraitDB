class CsvTemplateController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_is_admin
  before_filter :set_project

  def index
    @configs = @project.csv_import_configs.order('created_at DESC')
  end

  def info
    @config = @project.csv_import_configs.find(params[:id])
    @group = @project.trait_groups.find(params[:trait_group_id])
    @info = @config.generate_info(@group.id)
  end

  def download
    config = @project.csv_import_configs.find(params[:id])
    group = @project.trait_groups.find(params[:trait_group_id])
    @csv_data = config.generate_csv_template(group.id)
    respond_to do |format|
      format.csv do
        filename = "#{config.name}-#{group.name}-upload_template.csv"
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
end
