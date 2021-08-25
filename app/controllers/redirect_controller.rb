class RedirectController < ApplicationController
  skip_before_action :authorized

  URL_CACHE_EXPIRATION = 1.day

  def redirect_from_slug_to_url
    slug = request.path[1..-1] # Remove leading '/'

    # Try hitting cache before fetching from database
    redirect_url = Rails.cache.fetch(slug, expires_in: URL_CACHE_EXPIRATION) do
      @url = Url.find_by(slug: slug) rescue false
      render json: { error: "Did not find a matching shortened url." }, status: :not_found and return unless @url
      @url.original_url
    end

    redirect_to redirect_url
  end
end
