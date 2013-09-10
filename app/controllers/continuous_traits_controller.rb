class ContinuousTraitsController < ApplicationController
  before_filter :set_project
  def index
    where_options = {}
    if params[:otu]
      where_options[:otu_id] = params[:otu].to_i
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
    @total = @project.continuous_traits.where(where_options).count
    @continuous_traits = @project.continuous_traits.where(where_options).sorted.limit(@count).offset(@start)

  end

  def show
    @continuous_trait = @project.continuous_traits.find(params[:id])
  end

  def edit
    @continuous_trait = @project.continuous_traits.find(params[:id])
  end

  def update
    @continuous_trait = @project.continuous_traits.find(params[:id])
    if @continuous_trait.update_attributes(params[:continuous_trait])
      flash[:notice] = 'Trait updated successfully'
      redirect_to(:action => 'show', :id => @continuous_trait.id)
    else
      render('edit')
    end
  end
end
