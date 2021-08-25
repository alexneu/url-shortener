require 'rails_helper'

RSpec.describe "Urls", type: :request do
  describe "GET /urls" do
    before do
      post '/users', params: { user: { username: 'alex', password: 'authpassword' } }
      @token1 = JSON.parse(response.body)['jwt']

      post '/users', params: { user: { username: 'bob', password: 'coolpassword' } }
      @token2 = JSON.parse(response.body)['jwt']

      # @specified_url1 = Url.create(slug: 'slug1', original_url: 'http://www.goldbelly.com', user_id: @user1.id)
      # @specified_url2 = Url.create(slug: 'slug2', original_url: 'http://www.google.com', user_id: @user1.id)
      # @specified_url3_no_owner = Url.create(slug: 'slug1', original_url: 'http://www.cnn.com')
      # @random_url1 = Url.create(original_url: 'http://www.nytimes.com', user_id: @user1.id)
      # @random_url2 = Url.create(original_url: 'http://www.hackernews.com', user_id: @user2.id)
    end

    after do
      Url.destroy_all
      User.destroy_all
    end

    context 'authenticated user' do
      it 'should list user urls' do
        get "/urls", headers: { "Authorization" => "Bearer #{@token1}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'unauthenticated user' do
      it 'should return unauthorized error' do
        get "/urls"
        expect(response).to be_unauthorized
      end
    end
  end
end
