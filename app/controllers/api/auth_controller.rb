class Api::AuthController < Api::ApiController
  skip_before_action :authorized, only: [:create]
 
  def create
    @user = begin
      Api::User.find_by(username: user_login_params[:username])
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end  
    # authenticate method comes from bcrypt
    if @user&.authenticate(user_login_params[:password])
      @user.update_attribute(:last_login, Time.now)
      @token = encode_token({ user_id: @user.id.to_s })
      render json: { user: { username: @user.username }, jwt: @token }, status: :accepted
    else
      render json: { message: 'Invalid username or password' }, status: :unauthorized
    end
  end
 
  private
 
  def user_login_params
    params.require(:user).permit(:username, :password)
  end
end