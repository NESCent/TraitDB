class OtusController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :verify_is_admin, :except => [:index, :show]
  before_filter :set_project
  def index
    where_options = {}
    if params[:taxon]
      where_options['taxa.id'] = params[:taxon].to_i
    end
    if params[:import_job]
      where_options[:import_job_id] = params[:import_job].to_i
    end
    # TODO: add trait filters
    if params[:start]
      @start = params[:start].to_i
    else
      @start = 0
    end
    if params[:count]
      @count = params[:count].to_i
    else
      @count = 20
    end
    @total = @project.otus.joins(:taxa).where(where_options).count
    @otus = @project.otus.joins(:taxa).where(where_options).limit(@count).offset(@start)

  end

  def show
    @otu = @project.otus.find(params[:id])
  end

  def edit
    @otu = @project.otus.find(params[:id])
  end

  def update
    @otu = @project.otus.find(params[:id])
    if @otu.update_attributes(params[:otu])
      flash[:notice] = 'OTU updated successfully'
      redirect_to(:action => 'show', :id => otu.id)
    else
      render('edit')
    end
  end

  def destroy
    otu = @project.otus.find(params[:id])
    otu.destroy
    flash[:notice] = 'OTU destroyed successfully'
    redirect_to(:action => 'index')
  end

end
