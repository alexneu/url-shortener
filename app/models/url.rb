require 'digest/md5'

class Url < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  MAX_SLUG_LENGTH = 32
  RANDOM_SLUG_LENGTH = 6 
  # 64^6 = 69 billion records. 
  # Will probably start to see conflicts after a couple million records due to "Birthday Problem" logic, so we implemented some retries in the controller, 
  # and we can always add more characters to the slug, with each one reducing the chance of a conflict by 64X.

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
    # Remove problematic user-chosen url characters.
    def prep_user_slug(params)
      params[:slug].gsub!(/[^0-9a-zA-Z\-\_]/i, '')
    end

    def prep_random_slug(params)
      params[:slug] = generate_slug(params[:original_url])
    end

    # Randomly generated MD5 base64 digest, truncated, replace + and / since those can't go in url
    def generate_slug(url)
      nonced_url = url + Time.now.strftime("%s")
      Digest::MD5.base64digest(nonced_url)[0...(RANDOM_SLUG_LENGTH-1)].gsub('/', '+').gsub('-', '_')
    end
  end
end
