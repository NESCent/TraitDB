class ContinuousTraitValuesController < ApplicationController
  # Not project specific
  def index
    where_options = {}
    if params[:otu]
      where_options[:otu_id] = params[:otu].to_i
    end
    if params[:continuous_trait]
      where_options[:continuous_trait_id] = params[:continuous_trait].to_i
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
    @total = ContinuousTraitValue.where(where_options).count
    @continuous_trait_values = ContinuousTraitValue.where(where_options).sorted.limit(@count).offset(@start)
  end

  def show
    @continuous_trait_value = ContinuousTraitValue.find(params[:id])
  end


end
