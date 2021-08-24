class UrlsController < ApplicationController
  skip_before_action :authorized, only: [:create]
  before_action :set_url, only: [:show, :update, :destroy]

  # GET /urls
  def index
    @urls = Url.where(user_id: current_user.id)

    render json: @urls
  end

  # GET /urls/1
  def show
    render json: @url
  end

  # POST /urls
  def create
    url_params[:user_id] = current_user.id if logged_in?
    @url = Url.new(Url.prep_params(url_params))

    if @url.save
      render json: @url, status: :created, location: @url
    else
      render json: @url.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /urls/1
  def update
    if @url.update(url_params)
      render json: @url
    else
      render json: @url.errors, status: :unprocessable_entity
    end
  end

  # DELETE /urls/1
  def destroy
    @url.destroy
  end

  private
    def set_url
      @url = Url.find(params[:id])
    end

    def url_params
      params.require(:url).permit(:slug, :original_url, :expiration)
    end
end