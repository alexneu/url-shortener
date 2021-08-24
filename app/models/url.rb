require 'digest/md5'

class Url < ApplicationRecord
  include Mongoid::Document

  MAX_SLUG_LENGTH = 32

  # Expiration is a string representing timestamp seconds_since_epoch
  field :expiration, type: Time, default: ->{ Time.now + 2.years }
  field :original_url, type: String
  field :slug, type: String

  validates :expiration, presence: true, future_time: true
  validates :original_url, presence: true, http_url: true
  validates :slug, presence: true, uniqueness: true, length: { maximum: MAX_SLUG_LENGTH } 

  belongs_to :user, index: true, optional: true

  index({ slug: 1 }, { unique: true})

  class << self
    # Convert expiration from unix epoch timestamp to ruby Time class
    # Remove non-allowed characters from client slug, or generate one with MD5 base64 hashing and truncation
    def prep_params(params)
      params[:expiration] = Time.at(params[:expiration].to_i) if params[:expiration]
      # Base64 digest, replace problematic url characters.
      if params[:slug]
        params[:slug].gsub!(/[^0-9a-zA-Z\-\_]/i, '')
      else
        params[:slug] = generate_slug(params[:original_url]) unless params[:slug]
      end
      params
    end

    def generate_slug(url)
      nonced_url = url + Time.now.strftime("%s")
      Digest::MD5.base64digest(nonced_url)[0...8].gsub('/', '+').gsub('-', '_')
    end
  end
end
