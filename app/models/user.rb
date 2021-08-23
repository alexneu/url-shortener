class User
  include Mongoid::Document
  field :username, type: String
  field :password_digest, type: String
  field :last_login, type: Time

  has_many :urls, dependent: :destroy 
end
