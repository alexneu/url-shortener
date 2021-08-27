require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /api/login" do
    before do
      @user = Api::User.create(username: 'alex', password: 'authpassword')
    end

    after do 
      Api::User.destroy_all
    end

    context 'with valid username and password' do
      it 'should authenticate successfully' do
        post '/api/login', params: { user: { username: 'alex', password: 'authpassword' } }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['user']).to include({ 'username' => 'alex' })
        expect(response.body).to include('jwt')
      end
    end

    context 'with invalid username' do
      it 'should fail authorization' do
        post '/api/login', params: { user: { username: 'alejandro', password: 'authpassword' } }
        expect(response).to be_unauthorized
      end
    end

    context 'valid username, invalid password' do
      it 'should fail authorization' do
        post '/api/login', params: { user: { username: 'alex', password: 'wrongpassword' } }
        expect(response).to be_unauthorized
      end
    end
  end
end
