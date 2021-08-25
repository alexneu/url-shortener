class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    # TODO: Use an actual secret from the SECRET_KEY_BASE environment var
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
 
  def auth_header
    request.headers['Authorization']
  end
 
  def decoded_token
    if auth_header
      # headers: { 'Authorization': 'Bearer <token>' }
      token = auth_header.split(' ')[1]
    
      begin
      JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
  
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      # decoded_token => [{ "user_id" => 1 }, { "alg" => "HS256" }]
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
