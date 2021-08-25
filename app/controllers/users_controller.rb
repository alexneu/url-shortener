class UsersController < ApplicationController
  skip_before_action :authorized, only: [:create]
 
  # POST /users
  def create
    @user = User.create(user_params.merge({last_login: Time.now}))
    if @user.valid?
      @token = encode_token(user_id: @user.id.to_s)
      render json: { user: { username: @user.username }, jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :password)
    end
end
