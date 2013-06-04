class CategoricalTraitsController < ApplicationController

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
    @total = CategoricalTrait.where(where_options).count
    @categorical_traits = CategoricalTrait.where(where_options).sorted.limit(@count).offset(@start)

  end

  def show
    @categorical_trait = CategoricalTrait.find(params[:id])
  end

  def edit
    @categorical_trait = CategoricalTrait.find(params[:id])
  end

  def update
    @categorical_trait = CategoricalTrait.find(params[:id])
    if @categorical_trait.update_attributes(params[:categorical_trait])
      flash[:notice] = 'Trait updated successfully'
      redirect_to(:action => 'show', :id => @categorical_trait.id)
    else
      render('edit')
    end
  end

end
