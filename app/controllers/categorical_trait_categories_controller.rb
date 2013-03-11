class CategoricalTraitCategoriesController < ApplicationController
  def index
    where_options = {}
    if params[:otu]
      where_options[:otu_id] = params[:otu].to_i
    end
    if params[:categorical_trait]
      where_options[:categorical_trait_id] = params[:categorical_trait].to_i
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
    @total = CategoricalTraitCategory.count
    @categorical_trait_categories = CategoricalTraitCategory.where(where_options).sorted.limit(@count).offset(@start)

  end

  def show
    @categorical_trait_category = CategoricalTraitCategory.find(params[:id])
  end
end
