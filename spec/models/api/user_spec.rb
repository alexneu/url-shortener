require 'rails_helper'

RSpec.describe Api::User, type: :model do
  before do 
    travel_to Time.local(2021)
  end

  after do
    Api::User.destroy_all
    travel_back
  end

  describe '#new' do
    it "is valid with a username and a password" do
      user = Api::User.create(username: 'alex', password: 'coolpassword', last_login: Time.now)
      expect(user).to be_valid
      expect(user.username).to eq 'alex'
      expect(user.last_login).to eq Time.now
    end

    it "will not let you create a duplicate username" do
      user1 = Api::User.create(username: 'alex', password: 'coolpassword2')
      user2 = Api::User.create(username: 'alex', password: 'coolpassword')
      expect(user2).to_not be_valid
    end

    it "will not let you create a duplicate username, case insensitive" do
      user1 = Api::User.create(username: 'alex', password: 'coolpassword2')
      user2 = Api::User.create(username: 'alex', password: 'coolpassword')
      expect(user2).to_not be_valid
    end

    it "is not valid without a username" do
      user = Api::User.new(password: 'coolpassword', last_login: Time.now)
      expect(user).to_not be_valid
    end

    it "is not valid without a password" do
      user = Api::User.new(username: 'Bob', last_login: Time.now)
      expect(user).to_not be_valid
    end

    it 'generates a password_digest for the user password' do
      user = Api::User.new(username: 'Bob', password: 'coolpassword')
      expect(user.password_digest).to be_truthy
    end

    it 'does not save plaintext password to database' do
      user = Api::User.create(username: 'Cliff', password: 'coolpassword')
      user_id = user.id
      fetched_user = Api::User.find(user_id)
      expect(fetched_user.password).to be_nil
    end
  end
end
