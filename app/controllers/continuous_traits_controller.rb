class ContinuousTraitsController < ApplicationController

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
    @total = ContinuousTrait.where(where_options).count
    @continuous_traits = ContinuousTrait.where(where_options).sorted.limit(@count).offset(@start)

  end

  def show
    @continuous_trait = ContinuousTrait.find(params[:id])
  end
end
