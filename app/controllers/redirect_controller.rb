class RedirectController < ApplicationController
  skip_before_action :authorized

  URL_CACHE_EXPIRATION = 1.day

  def redirect_from_slug_to_url
    slug = request.path[1..-1] # Remote leading /

    redirect_url = Rails.cache.fetch(slug, expires_in: URL_CACHE_EXPIRATION) do
      @url = Url.find_by(slug: slug)
      if !@url
        render json: { error: "Did not find a matching shortened url." }, status: :not_found and return
      end
      @url.original_url
    end

    redirect_to redirect_url
  end
end
