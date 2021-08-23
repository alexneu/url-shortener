class ApplicationController < ActionController::API
  before_action :set_user

  private
    def set_user
      # Presumably fetch the user_id from some kind of session authentication token
      @user = User.find(user_id)
    end
end
