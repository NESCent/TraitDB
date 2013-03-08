class OtusController < ApplicationController
  before_filter :confirm_logged_in, :except => [:index, :show]

  def index
    where_options = {}
    if params[:taxon]
      where_options[:taxon_id] = params[:taxon].to_i
    end
    if params[:import_job]
      where_options[:import_job_id] = params[:import_job].to_i
    end
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
      @total = Otu.count
      @otus = Otu.where(where_options).sorted.limit(@count).offset(@start)

  end

  def show
    otu = Otu.find(params[:id])
  end

  def edit
    @otu= Otu.find(params[:id])
  end

  def update
    @otu = Otu.find(params[:id])
    if @otu.update_attributes(params[:otu])
      flash[:notice] = 'OTU updated successfully'
      redirect_to(:action => 'show', :id => otu.id)
    else
      render('edit')
    end
  end

  def destroy
    otu = Otu.find(params[:id])
    otu.destroy
    flash[:notice] = 'OTU destroyed successfully'
    redirect_to(:action => 'index')
  end

end
