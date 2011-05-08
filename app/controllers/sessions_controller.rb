class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])

    if user.nil?
      # Create an error message and re-render the signin form
			gflash :error => "There seems to be a problem with your email/password combination. Make sure they are correct!"
      render :action => "new"
    else
      # Sign the user in and redirect them
      sign_in user
      redirect_back_or user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end