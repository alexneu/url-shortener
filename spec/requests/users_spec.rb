require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    after do 
      User.destroy_all
    end

    context 'with valid username and password' do
      it 'should successfully create a user and return a username and token' do
        post '/users', params: { user: { username: 'alex', password: 'authpassword' } }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['user']).to include({ 'username' => 'alex' })
        expect(response.body).to include('jwt')
      end
    end

    context 'with missing username' do
      it 'should return an error' do
        post '/users', params: { user: { password: 'authpassword' } }
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context 'with missing password' do
      it 'should return an error' do
        post '/users', params: { user: { username: 'alex' } }
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context 'with duplicate username' do
      it 'should return an error' do
        post '/users', params: { user: { username: 'alex', password: 'authpassword' } }
        expect(response).to be_successful
        post '/users', params: { user: { username: 'alex', password: 'authpassword' } }
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
