class UrlsController < ApplicationController
  skip_before_action :authorized, only: [:create]
  before_action :set_url, only: [:show, :update, :destroy]

  RANDOM_SLUG_CREATION_RETRIES = 3

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
    create_params = url_params
    create_params[:user_id] = current_user.id.to_s if logged_in?
    create_params[:expiration] = Time.at(params[:expiration].to_i) if params[:expiration]
    create_params[:slug].present? ? create_user_slug_url(create_params) : create_random_slug_url(create_params)
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
      params.require(:url).permit(:expiration, :original_url, :slug)
    end

    def create_user_slug_url(create_params)
      Url.prep_user_slug(create_params)
      @url = Url.new(create_params)
      if @url.save
        render json: @url, status: :created, location: @url
      else
        render json: @url.errors, status: :unprocessable_entity
      end
    end

    def create_random_slug_url(create_params)
      retries = 0

      begin
        Url.prep_random_slug(create_params)
        @url = Url.new(create_params)
        if @url.save
          render json: @url, status: :created, location: @url and return  # and return just so we don't forget and put more executable code after this if/else
        else
          raise 'Error creating new shortened url'
        end
      rescue
        # Retry if error is due to randomly-generated slug conflict
        # TODO: Add logging if we fail due to conflict
        # That's a red alert that we need to add a few characters to our digests / implement a slug generation service
        retry if slug_conflict_error?(@url.errors) && (retries += 1) < RANDOM_SLUG_CREATION_RETRIES
        render json: @url.errors, status: :unprocessable_entity
      end
    end

    def slug_conflict_error? (errors)
      return false unless errors.size == 1
      errors.where(:slug, :taken).present?
    end
end