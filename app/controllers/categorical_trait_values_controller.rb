class CategoricalTraitValuesController < ApplicationController
  def index
    where_options = {}
    if params[:otu]
      where_options[:otu_id] = params[:otu].to_i
    end
    if params[:categorical_trait]
      where_options[:categorical_trait_id] = params[:categorical_trait].to_i
    end
    if params[:categorical_trait_category]
      where_options[:categorical_trait_category_id] = params[:categorical_trait_category].to_i
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
    @total = CategoricalTraitValue.count
    @categorical_trait_values = CategoricalTraitValue.where(where_options).sorted.limit(@count).offset(@start)

  end
end
