require "rails_helper"

RSpec.describe "Authentication" do
  before do
    Rails.application.routes.draw do
      get "/test" => "test#index"
    end
  end

  after do
    Rails.application.reload_routes!
    User.destroy_all
  end

  context "when the user provides a valid api token" do
    it "allows the user to pass" do
      user = User.create(username: 'alex', password: 'coolpassword')
      token = JWT.encode({ user_id: user.id.to_s }, Rails.application.credentials.secret_key_base)

      get "/test", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to be_successful
      expect(response.body).to eq({ "message" => "Hello world!" }.to_json)
    end
  end

  context "when the user provides an invalid api token" do
    it "does not allow to user to pass" do
      user = User.create(username: 'alex', password: 'coolpassword')
      token = JWT.encode({ user_id: user.id.to_s }, 'not-secret')

      get "/test", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to be_unauthorized
    end
  end

  private

  TestController = Class.new(ApplicationController) do
    def index
      render json: { message: "Hello world!" }
    end
  end

  def authenticate_with_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end