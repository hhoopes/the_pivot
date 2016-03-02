class SessionsController < ApplicationController

  def index

  end

  def new

  end

  def create
    user = User.find_by(username: params[:session][:username])

    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      redirect_to dashboard_path
    else
      flash.now[:error] = "Invalid Login"
      render :new
    end
  end
end
