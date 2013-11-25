class CsvTemplateController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_project

  def index
    @configs = @project.csv_import_configs.order('created_at DESC')
  end

  def info
    @config = @project.csv_import_configs.find(params[:id])
    @trait_group_name = params[:trait_group_name];
    @info = @config.generate_info(@trait_group_name)
  end

  def download
    config = @project.csv_import_configs.find(params[:id])
    trait_group_name = params[:trait_group_name]
    @csv_data = config.generate_csv_template(trait_group_name)
    respond_to do |format|
      format.csv do
        filename = "#{config.name}-#{trait_group_name}-upload_template.csv"
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
