class RedirectController < ApplicationController
  def redirect_from_slug_to_url
    slug = request.path
    @url = @url.find(slug: slug)
    if @url
      redirect_to @url.original_url
    else
      render json: { error: "Did not find a matching shortened url." }, status: :not_found
    end
  end
end
