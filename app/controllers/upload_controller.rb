# Non-restful controller for handling data uploads

class UploadController < ApplicationController
  before_filter :authenticate_user!
  def index
    # show the uploaded datasets
    @datasets = CsvDataset.order('created_at DESC')
  end

  def show
    @dataset = CsvDataset.find(params[:id])
  end

  def new
    @dataset = CsvDataset.new
  end

  def create
    @dataset = CsvDataset.new(params[:dataset])
    #@dataset.project = Project.first
    @dataset.user = current_user
    if @dataset.save
      flash[:notice] = 'Dataset created successsfully'
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

end
