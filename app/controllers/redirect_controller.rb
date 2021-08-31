class RedirectController < ApplicationController
  URL_CACHE_EXPIRATION = 1.day

  def redirect_from_slug_to_url
    slug = request.path[1..-1] # Remove leading '/'

    # Try hitting cache before fetching from database
    redirect_url = Rails.cache.fetch(slug, expires_in: URL_CACHE_EXPIRATION) do
      begin
        @url = Api::Url.find_by(slug: slug)
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: "Did not find a matching shortened url." }, status: :not_found and return
      end
      @url.original_url
    end

    redirect_to redirect_url
  end
end
