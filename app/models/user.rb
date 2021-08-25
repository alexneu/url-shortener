class User < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  field :username, type: String
  field :password_digest, type: String
  field :last_login, type: Time

  has_many :urls, dependent: :destroy

  has_secure_password
  validates :username, uniqueness: { case_sensitive: false }
end