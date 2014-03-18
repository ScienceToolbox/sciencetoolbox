class Users::ProfilesController < ApplicationController
  def index
  end

  def show
    @user = User.find(params[:user_id])
    @tools = @user.tools
  end
end
