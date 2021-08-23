class UrlsController < ApplicationController
  before_action :verify_authentication, only: [:index, :show, :update, :destroy]
  before_action :set_url, only: [:show, :update, :destroy]

  # GET /urls
  def index
    @urls = Url.where(user_id: @user.id)

    render json: @urls
  end

  # GET /urls/1
  def show
    render json: @url
  end

  # POST /urls
  def create
    create_params = url_params
    url_params.merge!(user_id: @user.id) if @user_id
    @url = Url.new(create_params)

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
    # Only let users destroy urls that they own
    render json: { errors: "Unauthenticated" }, :status => 401 unless @user
    @url.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_url
      @url = Url.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def url_params
      params.require(:url).permit(:slug, :original_url, :expiration)
    end

    def verify_authentication
      render json: { errors: "Unauthenticated" }, :status => 401 unless @user
    end
end