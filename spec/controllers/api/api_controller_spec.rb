require 'rails_helper'

RSpec.describe Api::ApiController, type: :controller do
  controller do
    def test
      render json: { message: "Test!" }
    end
  end

  before do
    routes.draw { get "test" => "api/api#test" }
  end

  after do
    Api::User.destroy_all
  end

  context 'when the user provides a valid api token' do
    it 'allows the user to pass' do
      user = Api::User.create(username: 'alex', password: 'coolpassword')
      token = JWT.encode({ user_id: user.id.to_s }, Rails.application.credentials.secret_key_base)
      request.headers.merge!(authenticated_header(token))
      get :test

      expect(response).to be_successful
      expect(response.body).to eq({ 'message' => 'Test!' }.to_json)
    end
  end

  context 'when the user provides an invalid api token' do
    it 'does not allow to user to pass' do
      user = Api::User.create(username: 'alex', password: 'coolpassword')
      token = JWT.encode({ user_id: user.id.to_s }, 'not-secret')
      request.headers.merge!(authenticated_header(token))
      get :test

      expect(response).to be_unauthorized
    end
  end

  private

  def authenticate_with_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def authenticated_header(token)
    { 'Authorization' => "Bearer #{token}" }
  end
end
