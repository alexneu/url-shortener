require 'digest/md5'

class Url
  include Mongoid::Document

  MAX_SLUG_LENGTH = 32

  # Expiration is a string representing timestamp seconds_since_epoch
  field :expiration, type: Time, default: ->{ Time.now + 2.years }
  field :original_url, type: String
  field :slug, type: String, index: true

  validates :expiration, presence: true, , future_time: true
  validates :original_url, presence: true, http_url: true
  validates_length_of :slug, maximum: MAX_SLUG_LENGTH

  belongs_to :user, index: true

  def initialize(user_id, slug, original_url, expiration)
    @user_id = user_id
    @original_url = original_url
    @expiration = Time.at(expiration) if expiration
    # Base64 digest, replace problematic url characters
    @slug = slug || Digest::MD5.base64digest(original_url)[0...8].gsub('/', '-').gsub('+', '_')
  end
end
