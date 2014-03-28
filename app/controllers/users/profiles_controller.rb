class Users::ProfilesController < ApplicationController
  def index
  end

  def show
    if params[:user_id]
      @user = User.find(params[:user_id])
    elsif params[:provider] && params[:username]
      @user = User.find_or_initialize_from_provider_and_username(
        params[:provider],
        params[:username]
      )
    end
    @tools = @user.tools
  end
end
