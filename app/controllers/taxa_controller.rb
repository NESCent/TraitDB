class TaxaController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    parent = Taxon.find(params[:parent_id]) if params[:parent_id]
    where_options = {}
    if params[:iczn_group_name]
      iczn_group = IcznGroup.find_by_name(params[:iczn_group_name])
      where_options[:iczn_group_id] = iczn_group.id
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
    if parent
      @total = parent.children.where(where_options).count
      @taxa = parent.children.where(where_options).sorted.limit(@count).offset(@start)
    else
      @total = Taxon.where(where_options).count
      @taxa = Taxon.where(where_options).sorted.limit(@count).offset(@start)
    end

  end

  def show
    @taxon = Taxon.find(params[:id])
  end
  
  def edit
    @taxon = Taxon.find(params[:id])
  end

  def update
    @taxon = Taxon.find(params[:id])
    if @taxon.update_attributes(params[:taxon])
      flash[:notice] = 'Taxon updated successfully'
      redirect_to(:action => 'show', :id => @taxon.id)
    else
      render('edit')
    end
  end

  def destroy
    taxon = Taxon.find(params[:id])
    taxon.otus.destroy_all
    taxon.children.destroy_all
    taxon.destroy
    flash[:notice] = 'Taxon destroyed successfully'
    redirect_to(:action => 'index')
  end

end
