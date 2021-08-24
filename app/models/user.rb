require 'bcrypt'

class User < ApplicationRecord
  include BCrypt
  include Mongoid::Document
  field :username, type: String
  field :last_login, type: Time

  has_many :urls, dependent: :destroy

  has_secure_password
  validates :username, uniqueness: { case_sensitive: false }
end
